module Buildr::IntellijIdea
  class IdeaFile
    # IDEA can not handle text content with indents so need to override this method and removing indenting
    # Can not pass true as third argument as ruby library seems broken
    def write(f)
      document.write(f, -1, false, true)
    end
  end

  class IdeaProject
    def artifacts
      @artifacts ||= []
    end

    def add_artifact(name, type, build_on_make = true)
      self.artifacts << lambda do
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target, :indent => 2).
          artifact(:name => name, :type => type, :"build-on-make" => build_on_make) do |xml|
          yield xml if block_given?
        end
        Buildr::IntellijIdea.new_document(target.string).root
      end

      self.components << lambda do
        cm = self.create_component("ArtifactManager")

        self.artifacts.each do |artifact|
          cm.add_element artifact.call
        end
        cm
      end
    end

    def add_exploded_war_configuration(project, options = {})
      artifact_name = options[:name] || project.iml.id
      build_on_make = options[:build_on_make].nil? ? true : options[:build_on_make]

      add_artifact(artifact_name, "exploded-war", build_on_make) do |xml|
        dependencies = (options[:dependencies] || ([project] + project.compile.dependencies)).flatten
        libraries, projects = partition_dependencies(dependencies)

        ## The content here can not be indented
        xml.tag!('output-path', project._(:artifacts, artifact_name))

        xml.root :id => "root" do
          xml.element :id => "directory", :name => "WEB-INF" do
            xml.element :id => "directory", :name => "classes" do
              projects.each do |p|
                xml.element :id => "module-output", :name => p.iml.id
              end
              if options[:enable_jpa]
                module_names = options[:jpa_module_names] || [project.iml.id]
                module_names.each do |module_name|
                  facet_name = options[:jpa_facet_name] || "JPA"
                  xml.element :id => "jpa-descriptors", :facet => "#{module_name}/jpa/#{facet_name}"
                end
              end
            end
            xml.element :id => "directory", :name => "lib" do
              libraries.each(&:invoke).map(&:to_s).each do |dependency_path|
                xml.element :id => "file-copy", :path => resolve_path(dependency_path)
              end
            end
          end

          if options[:enable_war].nil? || options[:enable_war]
            module_names = options[:war_module_names] || [project.iml.id]
            module_names.each do |module_name|
              facet_name = options[:war_facet_name] || "Web"
              xml.element :id => "javaee-facet-resources", :facet => "#{module_name}/web/#{facet_name}"
            end
          end

          if options[:enable_gwt]
            module_names = options[:gwt_module_names] || [project.iml.id]
            module_names.each do |module_name|
              facet_name = options[:gwt_facet_name] || "GWT"
              xml.element :id => "gwt-compiler-output", :facet => "#{module_name}/gwt/#{facet_name}"
            end
          end
        end
      end
    end

    def configurations
      @configurations ||= []
    end

    def add_configuration(name, type, factory_name, default = false)
      target = StringIO.new
      Builder::XmlMarkup.new(:target => target, :indent => 2).
        configuration(:name => name, :type => type, :factoryName => factory_name, :default => default) do |xml|
        yield xml if block_given?
      end
      self.configurations << Buildr::IntellijIdea.new_document(target.string).root

      self.components << lambda do
        cm = self.create_component("ProjectRunConfigurationManager")

        self.configurations.each do |configuration|
          cm.add_element configuration
        end
        cm
      end
    end

    def add_gwt_configuration(launch_page, project, options = {})

      name = options[:name] || "Run #{launch_page}"
      compile_parameters = options[:compile_parameters] || "-draftCompile -localWorkers 2"
      compile_max_heap_size = options[:compile_max_heap_size] || "512"

      add_configuration(name, "GWT.ConfigurationType", "GWT Configuration") do |xml|
        xml.module(:name => project.iml.id)
        xml.option(:name => "RUN_PAGE", :value => launch_page)
        xml.option(:name => "compilerParameters", :value => compile_parameters)
        xml.option(:name => "compilerMaxHeapSize", :value => compile_max_heap_size)

        xml.RunnerSettings(:RunnerId => "Run")
        xml.ConfigurationWrapper(:RunnerId => "Run")
        xml.method()
      end
    end

    # TODO: Migrate this down to IdeaFile and remove from here and IdeaModule
    def file_path(path)
      "file://#{resolve_path(path)}"
    end

    # Like resolve_path on IdeaModule except use $PROJECT_DIR$ constant
    # TODO: Make generic version and override in both subclasses
    def resolve_path(path)
      m2repo = Buildr::Repositories.instance.local
      if path.to_s.index(m2repo) == 0 && !buildr_project.iml.local_repository_env_override.nil?
        return path.sub(m2repo, "$#{buildr_project.iml.local_repository_env_override}$")
      else
        begin
          return "$PROJECT_DIR$/#{relative(path)}"
        rescue ArgumentError
          # ArgumentError happens on windows when self.base_directory and path are on different drives
          return path
        end
      end
    end

    # TODO: Migrate this down to IdeaFile and remove from here and IdeaModule
    def relative(path)
      ::Buildr::Util.relative_path(File.expand_path(path.to_s), self.base_directory)
    end

    # TODO: Migrate this down to IdeaFile and remove from here and IdeaModule
    def base_directory
      buildr_project.path_to
    end

    private

    def partition_dependencies(dependencies)
      libraries = []
      projects = []

      dependencies.each do |dependency|
        artifacts = Buildr.artifacts(dependency)
        artifacts_as_strings = artifacts.map(&:to_s)
        project = Buildr.projects.detect do |project|
          [project.packages, project.compile.target, project.resources.target, project.test.compile.target, project.test.resources.target].flatten.
            detect { |component| artifacts_as_strings.include?(component.to_s) }
        end
        if project
          projects << project
        else
          libraries += artifacts
        end
      end
      return libraries.uniq, projects.uniq
    end
  end

  class IdeaModule

    def add_gwt_facet(modules = {}, options = {})
      # This is needed when generators require annotations to access compiled classes in annotations.
      #  i.e. *PlaceHistoryMapper
      buildr_project.iml.main_source_directories << buildr_project.compile.target

      name = options[:name] || "GWT"
      settings =
        {
          :webFacet => "Web",
          :compilerMaxHeapSize => "512",
          :compilerParameters => "-draftCompile -localWorkers 2",
          :gwtSdkUrl => "file://$GWT_TOOLS$",
          :gwtScriptOutputStyle => "PRETTY"
        }.merge(options[:settings] || {})

      add_facet(name, "gwt") do |f|
        f.configuration do |c|
          settings.each_pair do |k, v|
            c.setting :name => k.to_s, :value => v.to_s
          end
          c.packaging do |d|
            modules.each_pair do |k, v|
              d.module :name => v, :path => k
            end
          end
        end
      end
    end

    def add_web_facet(options = {})
      name = options[:name] || "Web"
      url_base = options[:url_base] || "/"
      webroot = options[:webroot] || buildr_project._(:source, :main, :webapp)
      web_xml = options[:web_xml] || "#{webroot}/WEB-INF/web.xml"
      version = options[:version] || "3.0"

      add_facet(name, "web") do |f|
        f.configuration do |c|
          c.descriptors do |d|
            d.deploymentDescriptor :name => 'web.xml', :url => file_path(web_xml), :optional => "true", :version => version
          end
          c.webroots do |w|
            w.root :url => file_path(webroot), :relative => url_base
          end
        end
      end
    end

    def add_jruby_facet(options = {})
      name = options[:name] || "JRuby"
      jruby_version = options[:jruby_version] || "jruby-1.5.2-p249"
      add_facet(name, "JRUBY") do |f|
        f.configuration(:number => 0) do |c|
          c.JRUBY_FACET_CONFIG_ID :NAME => "JRUBY_SDK_NAME", :VALUE => jruby_version
        end
      end
    end

    def add_jpa_facet(options = {})
      name = options[:name] || "JPA"
      factory_entry = options[:factory_entry] || buildr_project.name.to_s
      validation_enabled = options[:validation_enabled] || true
      provider_enabled = options[:provider_enabled] || 'Hibernate'
      persistence_xml = options[:persistence_xml] || buildr_project._(:source, :main, :resources, "META-INF/persistence.xml")
      orm_xml = options[:orm_xml] || buildr_project._(:source, :main, :resources, "META-INF/orm.xml")
      add_facet(name, "jpa") do |f|
        f.configuration do |c|
          c.setting :name => "validation-enabled", :value => validation_enabled
          c.setting :name => "provider-name", :value => provider_enabled
          c.tag!('datasource-mapping') do |ds|
            ds.tag!('factory-entry', :name => factory_entry)
          end
          if File.exist?(persistence_xml)
            c.deploymentDescriptor :name => 'persistence.xml', :url => file_path(persistence_xml)
          end
          if File.exist?(orm_xml)
            c.deploymentDescriptor :name => 'orm.xml', :url => file_path(orm_xml)
          end
        end
      end
    end

    def add_ejb_facet(options = {})
      name = options[:name] || "EJB"
      ejb_xml = options[:ejb_xml] || buildr_project._(:source, :main, :resources, "WEB-INF/ejb-jar.xml")
      ejb_roots = options[:ejb_roots] || [buildr_project.packages, buildr_project.compile.target, buildr_project.resources.target].flatten

      add_facet(name, "ejb") do |facet|
        facet.configuration do |c|
          c.descriptors do |d|
            d.deploymentDescriptor :name => 'ejb-jar.xml', :url => ejb_xml
          end
          c.ejbRoots do |e|
            ejb_roots.each do |ejb_root|
              e.root :url => file_path(ejb_root)
            end
          end
        end
      end
    end

  end
end
