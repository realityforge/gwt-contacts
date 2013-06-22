require 'buildr/git_auto_version'
require 'buildr/top_level_generate_dir'
require 'buildr/single_intermediate_layout'
require 'buildr/checkstyle'
require 'buildr/gwt'

SLF4J = [:slf4j_api, :slf4j_jdk14, :jcl_over_slf4j]
HIBERNATE = [:javax_persistence,
             :hibernate_annotations,
             :javax_transaction,
             :javax_validation,
             :hibernate_validator,
             :hibernate_entitymanager,
             :hibernate_core,
             :hibernate_ehcache,
             :hibernate_c3p0,
             :dom4j,
             :hibernate_commons_annotations,
             :javassist,
             :commons_collections,
             :antlr]

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
    iml.add_gwt_facet

    define_gwt_services_unit(project, :Contacts)

    package(:jar)
    package(:sources)
  end

  desc "GWT Contacts: Client-side component"
  define 'client' do
    iml.add_gwt_facet("/contacts" => "com.google.gwt.sample.contacts.ContactsDev")

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

    test.with :easymock, :mockito

    package(:jar)
    package(:sources)

    define_gwt_client_services(project, :Contacts)
  end

  desc "GWT Contacts: Server-side component"
  define 'server' do
    compile.with :gwt_user,
                 :gwt_dev,
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

    define_persistence_unit(project, :Contacts)
    define_services_unit(project, :Contacts)
    define_gwt_servlets(project, :Contacts)

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
                                           :gwt_dev,
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
      war.include "#{contact_module}/contacts"
      war.with :libs => [:gwt_user, :gwt_dev, project('shared').package(:jar), project('server')]
      war.enhance [contact_module]
    end
  end

  # Remove the IDEA generated artifacts
  project.clean { rm_rf project._(:artifacts) }

  doc.using :javadoc, { :tree => false, :since => false, :deprecated => false, :index => false, :help => false }
  doc.from projects('shared', 'client', 'server')

  ipr.add_exploded_war_artifact(project,
                                :name => 'gwt-contacts',
                                :enable_gwt => true,
                                :war_module_names => [project('web').iml.id],
                                :gwt_module_names => [project('client').iml.id, project('shared').iml.id],
                                :dependencies => [:gwt_user, :gwt_dev, projects('client', 'shared', 'server')])
  ipr.add_gwt_configuration("#{project.name}/Contacts.html", project('client'), :shell_parameters => "-noserver -port 8080")
  ipr.extra_modules << "../domgen/domgen.iml"
  ipr.extra_modules << "../replicant/replicant.iml"

  iml.add_jruby_facet

  checkstyle.config_directory = _('etc/checkstyle')
  checkstyle.source_paths << project('shared')._(:source, :main, :java)
  checkstyle.source_paths << project('client')._(:source, :main, :java)
  checkstyle.source_paths << project('server')._(:source, :main, :java)
  checkstyle.extra_dependencies << :javax_servlet
end
