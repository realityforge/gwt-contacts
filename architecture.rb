Domgen.define_repository(:Contacts) do |repository|
  repository.enable_facet(:sql)
  repository.enable_facet(:jpa)
  repository.enable_facet(:ejb)
  repository.enable_facet(:gwt)

  repository.define_data_module(:Contacts) do |data_module|
    data_module.gwt.module_name = "contacts"
    data_module.gwt.package = 'com.google.gwt.sample.contacts'
    data_module.jpa.entity_package = 'com.google.gwt.sample.contacts.server.entity'
    data_module.ejb.service_package = 'com.google.gwt.sample.contacts.server.service'

    data_module.define_service(:ContactsService) do |s|
      s.description("Contacts Service definition")

      s.method(:DeleteContacts) do |m|
        m.parameter(:IDS, "java.util.ArrayList<java.lang.String>")
      end
      s.method(:GetContactDetails) do |m|
        m.returns("java.util.ArrayList<com.google.gwt.sample.contacts.shared.ContactDetailsVO>")
      end
      s.method(:GetContact) do |m|
        m.string(:ID, 50)
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

    data_module.define_message(:AddContact)
    data_module.define_message(:ContactDeleted)
    data_module.define_message(:ContactUpdated) do |m|
      m.string(:ID, 50)
    end
    data_module.define_message(:AddContactCancelled)
    data_module.define_message(:EditContactCancelled) do |m|
      m.string(:ID, 50)
    end
    data_module.define_message(:ShowContact) do |m|
      m.string(:ID, 50)
    end
    data_module.define_message(:ContactClosed) do |m|
      m.string(:ID, 50)
    end
    data_module.define_message(:EditContact) do |m|
      m.string(:ID, 50)
    end

  end
end
