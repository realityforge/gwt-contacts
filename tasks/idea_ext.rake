module Buildr::IntellijIdea

  class IdeaProject
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

    def add_gwt_configuration(launch_page, iml_module_name, options = {})
      name = options[:name] ||  "Run #{launch_page}"

      add_configuration(name, "GWT.ConfigurationType", "GWT Configuration") do |xml|
        xml.module(:name => iml_module_name)
        xml.option(:name => "RUN_PAGE", :value => launch_page)
        xml.RunnerSettings(:RunnerId => "Run")
        xml.ConfigurationWrapper(:RunnerId => "Run")
        xml.method()
      end
    end
  end

  class IdeaModule

    def add_gwt_facet(modules, options = {})
      name = options[:name] || "GWT"
      settings =
        {
          :webFacet => "Web",
          :compilerMaxHeapSize => "128",
          :gwtSdkUrl => "file://$GWT_TOOLS$",
          :gwtScriptOutputStyle => "DETAILED"
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
      persistence_xml = options[:persistence_xml] || buildr_project._(:source, :main, :resources, "WEB-INF/web.xml")
      add_facet(name, "jpa") do |f|
        f.configuration do |c|
          c.setting :name => "validation-enabled", :value => validation_enabled
          c.setting :name => "provider-name", :value => provider_enabled
          c.tag!('datasource-mapping') do |ds|
            ds.tag!('factory-entry', :name => factory_entry)
          end
          c.descriptors do |d|
            d.deploymentDescriptor :name => 'persistence.xml', :url => file_path(persistence_xml)
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
