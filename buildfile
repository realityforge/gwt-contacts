require 'buildr/git_auto_version'
require 'buildr/top_level_generate_dir'
require 'buildr/single_intermediate_layout'
require 'buildr/checkstyle'
require 'buildr/jacoco'

JEE_GWT_JARS = [:javax_inject, :javax_annotation, :javax_validation, :javax_validation_sources]
GIN_JARS = [:gwt_gin, :google_guice, :aopalliance, :google_guice_assistedinject]
APPCACHE_GWT_JARS = [:gwt_appcache_client, :gwt_appcache_linker, :gwt_appcache_server]
GWT_JARS = JEE_GWT_JARS + GIN_JARS + [:gwt_user] + APPCACHE_GWT_JARS
JEE_JARS = [:javax_inject, :javax_servlet, :javax_ejb, :javax_persistence, :javax_annotation, :javax_validation]
JACKSON_DEPS = [:jackson_core, :jackson_mapper]
PROVIDED_DEPS = JACKSON_DEPS + JEE_JARS
INCLUDED_DEPENDENCIES = [:gwt_user, :gwt_appcache_server, :gwt_cache_filter]

desc "GWT Contacts: Sample application showing off our best practices"
define 'gwt-contacts' do
  project.group = 'org.realityforge.gwt.contacts'

  compile.options.source = '1.7'
  compile.options.target = '1.7'
  compile.options.lint = 'all'

  desc "GWT Contacts: Client-side component"
  define 'client' do
    Domgen::GenerateTask.new(:Contacts,
                             "client",
                             [:gwt_client, :gwt_rpc_shared, :gwt_rpc_client, :gwt_client_jso],
                             _(:target, :generated, 'domgen'))

    compile.with GWT_JARS

    test.using :testng
    test.with :mockito

    package(:jar)
    package(:sources)

    iml.add_gwt_facet({'org.realityforge.gwt.sample.contacts.ContactsDev' => true,
                       'org.realityforge.gwt.sample.contacts.Contacts' => false},
                      :settings => {:compilerMaxHeapSize => "1024"},
                      :gwt_dev_artifact => :gwt_dev)
  end

  desc "GWT Contacts: Server-side component"
  define 'server' do
    Domgen::GenerateTask.new(:Contacts,
                             "server",
                             [:ee_data_types, :ee, :gwt_rpc_shared, :gwt_rpc_server, :jpa_test_module],
                             _(:target, :generated, 'domgen'))

    compile.with PROVIDED_DEPS + INCLUDED_DEPENDENCIES

    test.compile.with :guiceyloops,
                      :google_guice,
                      :aopalliance,
                      :google_guice_assistedinject,
                      :h2db,
                      :javax_persistence,
                      :eclipselink
    package(:jar)

    iml.add_jpa_facet
    iml.add_ejb_facet
  end

  desc "GWT Contacts: Web component"
  define 'web' do
    iml.add_web_facet

    gwt(["org.realityforge.gwt.sample.contacts.Contacts"],
        :dependencies => [project('client').compile.dependencies,
                          # The following picks up both the jar and sources
                          # packages deliberately. It is needed for the
                          # generators to access classes in annotations.
                          project('client')],
        :java_args => ["-Xms512M", "-Xmx512M", "-XX:PermSize=128M", "-XX:MaxPermSize=256M"],
        :draft_compile => (ENV["FAST_GWT"] == 'true'))

    package(:war).tap do |war|
      war.with :libs => [INCLUDED_DEPENDENCIES, project('server')]
    end
  end

  # Remove the IDEA generated artifacts
  project.clean { rm_rf project._(:artifacts) }
  project.clean { rm_rf _('database/generated') }

  doc.using :javadoc, { :tree => false, :since => false, :deprecated => false, :index => false, :help => false }
  doc.from projects('client', 'server')

  ipr.add_exploded_war_artifact(project,
                                :war_module_names => [project('web').iml.id],
                                :jpa_module_names => [project('server').iml.id],
                                :ejb_module_names => [project('server').iml.id],
                                :gwt_module_names => [project('client').iml.id],
                                :dependencies => [INCLUDED_DEPENDENCIES, projects('server')])
  ipr.add_gwt_configuration("#{project.name}/Contacts.html", project('client'), :shell_parameters => "-noserver -port 8080")

  iml.add_jruby_facet

  checkstyle.config_directory = _('etc/checkstyle')
  checkstyle.source_paths << project('client')._(:source, :main, :java)
  checkstyle.source_paths << project('server')._(:source, :main, :java)
  checkstyle.extra_dependencies << PROVIDED_DEPS
  checkstyle.extra_dependencies << INCLUDED_DEPENDENCIES
end
