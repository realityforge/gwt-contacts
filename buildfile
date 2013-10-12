require 'buildr/git_auto_version'
require 'buildr/top_level_generate_dir'
require 'buildr/single_intermediate_layout'
require 'buildr/checkstyle'
require 'buildr/gwt'

desc "GWT Contacts: Sample application showing off our best practices"
define 'gwt-contacts' do
  project.group = 'org.realityforge.gwt.contacts'

  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  desc "GWT Contacts: Shared component"
  define 'shared' do
    compile.with :javax_annotation,
                 :replicant,
                 :replicant_sources,
                 :javax_inject,
                 :gwt_user

    iml.add_gwt_facet({}, :gwt_dev_artifact => :gwt_dev)

    Domgen::GenerateTask.new(:Contacts,
                             "shared",
                             [:gwt_rpc_shared],
                             _(:target, :generated, "domgen"),
                             project)

    package(:jar)
    package(:sources)
  end

  desc "GWT Contacts: Client-side component"
  define 'client' do
    iml.add_gwt_facet({"/contacts" => "com.google.gwt.sample.contacts.ContactsDev"},
                      :gwt_dev_artifact => :gwt_dev)

    compile.with :gwt_user,
                 :javax_annotation,
                 :google_guice,
                 :aopalliance,
                 :google_guice_assistedinject,
                 :javax_inject,
                 :replicant,
                 :replicant_sources,
                 :gwt_gin,
                 project('shared').package(:jar)

    test.with :easymock, :mockito, :json

    Domgen::GenerateTask.new(:Contacts,
                             "client",
                             [:gwt_client, :gwt_rpc_client, :gwt_client_jso, :auto_bean_enumeration],
                             #[:gwt_client_service_test, :gwt_client_service, :imit, :imit_json],
                             _(:target, :generated, "domgen"),
                             project)

    package(:jar)
    package(:sources)
  end

  desc "GWT Contacts: Server-side component"
  define 'server' do
    compile.with :gwt_user,
                 :gwt_dev,
                 :jackson_core,
                 :jackson_mapper,
                 :javax_inject,
                 :javax_servlet,
                 :javax_ejb,
                 :replicant,
                 :javax_persistence,
                 project('shared').package(:jar),
                 :javax_annotation,
                 :javax_validation
    iml.add_jpa_facet
    iml.add_ejb_facet

    Domgen::GenerateTask.new(:Contacts,
                             "server",
                             [:ee_data_types, :ee, :gwt_rpc_server, :jpa_test_module],
                             _(:target, :generated, "domgen"),
                             project)

    test.compile.with :guiceyloops,
                      :google_guice,
                      :aopalliance,
                      :google_guice_assistedinject,
                      :h2db,
                      'org.eclipse.persistence:javax.persistence:jar:2.0.1',
                      :eclipselink
    package(:jar)
  end

  desc "GWT Contacts: Web component"
  define 'web' do
    iml.add_web_facet

    contact_module = gwt(["com.google.gwt.sample.contacts.Contacts"],
                         :dependencies => [project('client').compile.dependencies,
                                           :gwt_user,
                                           # The following picks up both the jar and sources
                                           # packages deliberately. It is needed for the
                                           # generators to access classes in annotations.
                                           project('client'),
                                           project('shared'),
                                           # Validation needed to quieten warnings from gwt compiler
                                           :replicant,
                                           :replicant_sources,
                                           :javax_validation,
                                           :javax_validation_sources],
                         :java_args => ["-Xms512M", "-Xmx512M", "-XX:PermSize=128M", "-XX:MaxPermSize=256M"],
                         :draft_compile => (ENV["FAST_GWT"] == 'true'))

    package(:war).tap do |war|
      war.include "#{contact_module}/WEB-INF"
      war.include file("#{contact_module}/contacts" => [contact_module])
      war.with :libs => [:gwt_user,
                         project('shared').package(:jar),
                         project('server')]
    end
  end

  # Remove the IDEA generated artifacts
  project.clean { rm_rf project._(:artifacts) }

  doc.using :javadoc, { :tree => false, :since => false, :deprecated => false, :index => false, :help => false }
  doc.from projects('shared', 'client', 'server')

  ipr.add_exploded_war_artifact(project,
                                :war_module_names => [project('web').iml.id],
                                :gwt_module_names => [project('client').iml.id, project('shared').iml.id],
                                :dependencies => [:gwt_user, :gwt_dev, projects('client', 'shared', 'server')])
  ipr.add_gwt_configuration("#{project.name}/Contacts.html", project('client'), :shell_parameters => "-noserver -port 8080")

  iml.add_jruby_facet

  checkstyle.config_directory = _('etc/checkstyle')
  checkstyle.source_paths << project('shared')._(:source, :main, :java)
  checkstyle.source_paths << project('client')._(:source, :main, :java)
  checkstyle.source_paths << project('server')._(:source, :main, :java)
  checkstyle.extra_dependencies << :javax_servlet
end
