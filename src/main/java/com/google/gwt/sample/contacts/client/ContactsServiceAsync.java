package com.google.gwt.sample.contacts.client;

import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.ArrayList;

public interface ContactsServiceAsync
{
  void deleteContacts( ArrayList<String> ids, AsyncCallback<Void> callback );

  void getContactDetails( AsyncCallback<ArrayList<ContactDetails>> callback );

  void getContact( String id, AsyncCallback<Contact> callback );

  void createOrUpdateContact( Contact contact, AsyncCallback<Contact> callback );
}

