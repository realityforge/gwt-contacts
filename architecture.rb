Domgen.repository(:Contacts) do |repository|
  repository.enable_facet(:sql)
  repository.enable_facet(:jpa)
  repository.enable_facet(:ejb)
  repository.enable_facet(:gwt_rpc)
  repository.enable_facet(:json)
  repository.enable_facet(:jackson)

  repository.gwt_rpc.module_name = 'contacts'
  repository.java.base_package = 'org.realityforge.gwt.sample.contacts'

  repository.data_module(:Contacts) do |data_module|
    data_module.struct(:ContactDetailsDTO) do |ss|
      ss.text(:ID)
      ss.text(:Type)
      ss.text(:DisplayName)
    end

    data_module.struct(:ContactDTO) do |ss|
      ss.text(:ID, :nullable => true)
      ss.text(:Type, :nullable => true)
      ss.text(:FirstName)
      ss.text(:LastName)
      ss.text(:EmailAddress)
    end

    data_module.service(:ContactsService) do |s|
      s.method(:DeleteContacts) do |m|
        m.text(:ID, :collection_type => :sequence)
      end
      s.method(:GetContactDetails) do |m|
        m.returns(:struct, :referenced_struct => :ContactDetailsDTO, :collection_type => :sequence)
      end
      s.method(:GetContact) do |m|
        m.string(:ID, 50)
        m.returns(:struct, :referenced_struct => :ContactDTO)
      end
      s.method(:CreateOrUpdateContact) do |m|
        m.struct(:Contact, :ContactDTO)
        m.returns(:struct, :referenced_struct => :ContactDTO)
      end
    end

    data_module.entity(:ContactType) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:Name, 50)
      t.string(:RenderCode, 50)

      t.query(:FindByName)
    end

    data_module.entity(:Contact) do |t|
      t.integer(:ID, :primary_key => true)
      t.reference(:ContactType)
      t.string(:FirstName, 500, :nullable => true)
      t.string(:LastName, 500, :nullable => true)
      t.string(:EmailAddress, 500, :nullable => true)
    end

    data_module.message(:AddContact)
    data_module.message(:ContactDeleted)
    data_module.message(:ContactUpdated) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:AddContactCancelled)
    data_module.message(:EditContactCancelled) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:ShowContact) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:ContactClosed) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:EditContact) do |m|
      m.string(:ID, 50)
    end
  end
end
