Domgen.define_repository(:Contacts) do |repository|
  repository.enable_facet(:sql)
  repository.enable_facet(:java)
  repository.enable_facet(:jpa)
  repository.enable_facet(:ejb)
  repository.enable_facet(:gwt)

  repository.gwt.package = 'com.google.gwt.sample.contacts'

  repository.define_data_module(:Contacts) do |data_module|
    data_module.java.package = 'com.google.gwt.sample.contacts.server'

    data_module.define_service(:Contacts) do |s|
      s.description("Contacts Service definition")

      s.method(:DeleteContacts) do |m|
        m.parameter(:IDS, "java.util.ArrayList<java.lang.String>")
      end
      s.method(:GetContactDetails) do |m|
        m.returns("java.util.ArrayList<com.google.gwt.sample.contacts.shared.ContactDetailsVO>")
      end
      s.method(:GetContact) do |m|
        m.parameter(:ID, "java.lang.String")
        m.returns("com.google.gwt.sample.contacts.shared.ContactVO")
      end
      s.method(:CreateOrUpdateContact) do |m|
        m.parameter(:Contact, "com.google.gwt.sample.contacts.shared.ContactVO")
        m.returns("com.google.gwt.sample.contacts.shared.ContactVO")
      end
    end

    data_module.define_object_type(:Contact) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:FirstName, 500, :nullable => true)
      t.string(:LastName, 500, :nullable => true)
      t.string(:EmailAddress, 500, :nullable => true)
    end

  end
end
