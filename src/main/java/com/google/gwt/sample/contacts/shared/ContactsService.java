package com.google.gwt.sample.contacts.shared;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import java.util.ArrayList;

@RemoteServiceRelativePath( "contactsService" )
public interface ContactsService
  extends RemoteService
{
  void deleteContacts( ArrayList<String> ids );

  ArrayList<ContactDetails> getContactDetails();

  Contact getContact( String id );

  Contact createOrUpdateContact( Contact contact );
}
