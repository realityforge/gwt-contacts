package com.google.gwt.sample.contacts.shared;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.google.gwt.user.client.rpc.XsrfProtectedService;
import java.util.ArrayList;

@RemoteServiceRelativePath( "contactsService" )
public interface ContactsService
  extends XsrfProtectedService
{
  void deleteContacts( ArrayList<String> ids );

  ArrayList<ContactDetails> getContactDetails();

  Contact getContact( String id );

  Contact createOrUpdateContact( Contact contact );
}
