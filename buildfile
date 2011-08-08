desc "GWT Contacts: Sample application showing off our best practices"
define 'gwt-contacts' do
  project.version = '0.9-SNAPSHOT'
  project.group = 'org.realityforge.gwt.contacts'

  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  desc "GWT Contacts: Shared component"
  define 'shared' do
    compile.with :gwt_user
    iml.add_gwt_facet

    package(:jar)
    package(:sources)
  end

  desc "GWT Contacts: Client-side component"
  define 'client' do
    iml.add_gwt_facet("/contacts" => "com.google.gwt.sample.contacts.Contacts")

    compile.with :gwt_user, :smartgwt, project('shared').package(:jar)

    test.with :easymock

    package(:jar)
    package(:sources)
  end

  desc "GWT Contacts: Server-side component"
  define 'server' do
    compile.with :gwt_user, :javax_servlet, :javax_ejb, :javax_persistence, project('shared')
    iml.add_jpa_facet

    package(:jar)
  end

  desc "GWT Contacts: Web component"
  define 'web' do
    iml.add_web_facet

    contact_module = gwt(["com.google.gwt.sample.contacts.Contacts"],
                         :dependencies => [:gwt_user,
                                           :smartgwt,
                                           # The following picks up both the jar and sources
                                           # packages delliberately. It is needed for the
                                           # generators to access classes in annotations.
                                           project('client'),
                                           project('shared'),
                                           project('client').package(:sources),
                                           project('shared').package(:sources),
                                           # Validation needed to quieten warnings from gwt compiler
                                           :javax_validation,
                                           :javax_validation_sources],
                         :java_args => ["-Xms512M", "-Xmx512M", "-XX:PermSize=128M", "-XX:MaxPermSize=256M"],
                         :draft_compile => (ENV["FAST_GWT"] == 'true'))

    package(:war).tap do |war|
      war.include "#{contact_module}/WEB-INF"
      war.include "#{contact_module}/contacts"
      war.with :libs => [:gwt_user, project('shared').package(:jar), project('server')]
      war.enhance [contact_module]
    end
  end


  # Remove the IDEA generated artifacts
  project.clean { rm_rf project._(:artifacts) }

  doc.using :javadoc, {:tree => false, :since => false, :deprecated => false, :index => false, :help => false}
  doc.from projects('shared', 'client', 'server')

  ipr.add_exploded_war_configuration(project,
                                     :name => 'gwt-contacts',
                                     :enable_gwt => true,
                                     :war_module_names => [project('web').iml.id],
                                     :gwt_module_names => [project('client').iml.id, project('shared').iml.id],
                                     :dependencies => [:gwt_user, projects('shared', 'server')])
  ipr.add_gwt_configuration("#{project.name}/Contacts.html", project)

  iml.add_jruby_facet

  checkstyle.config_directory = _('etc/checkstyle')
  checkstyle.source_paths << project('shared').compile.sources
  checkstyle.source_paths << project('shared').test.compile.sources
  checkstyle.source_paths << project('client').compile.sources
  checkstyle.source_paths << project('client').test.compile.sources
  checkstyle.source_paths << project('server').compile.sources
  checkstyle.source_paths << project('server').test.compile.sources
end
