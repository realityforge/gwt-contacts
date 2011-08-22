package com.google.gwt.sample.contacts.shared;

import com.google.gwt.http.client.Request;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.ArrayList;

public interface ContactsServiceAsync
{
  Request deleteContacts( ArrayList<String> ids, AsyncCallback<Void> callback );

  Request getContactDetails( AsyncCallback<ArrayList<ContactDetailsVO>> callback );

  Request getContact( String id, AsyncCallback<ContactVO> callback );

  Request createOrUpdateContact( ContactVO contact, AsyncCallback<ContactVO> callback );
}

