desc "GWT Contacts: Sample application showing off our best practices"
define 'gwt-contacts' do
  project.version = '0.9-SNAPSHOT'
  project.group = 'org.realityforge.gwt.contacts'

  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  compile.with :easymock, :gwt_user

  contact_module = gwt("com.google.gwt.sample.contacts.Contacts", :dependencies => [:gwt_user, :javax_validation, :javax_validation_sources])

  package(:war).tap do |war|
    war.enhance [contact_module]
    war.include "#{contact_module}/*"
  end

  doc.using :javadoc,
            {:tree => false, :since => false, :deprecated => false, :index => false, :help => false}

  ipr.add_gwt_configuration("Contacts.html", project.iml.id)
  iml.add_web_facet
  iml.add_gwt_facet("/contacts" => "com.google.gwt.sample.contacts.Contacts")
  iml.add_jruby_facet
end
