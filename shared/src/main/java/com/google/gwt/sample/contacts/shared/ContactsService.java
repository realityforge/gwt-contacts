package com.google.gwt.sample.contacts.shared;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.google.gwt.user.client.rpc.XsrfProtectedService;
import java.util.ArrayList;

@RemoteServiceRelativePath( ContactsService.PATH )
public interface ContactsService
  extends XsrfProtectedService
{
  String PATH = "contactsService";

  void deleteContacts( ArrayList<String> ids );

  ArrayList<ContactDetailsVO> getContactDetails();

  ContactVO getContact( String id );

  ContactVO createOrUpdateContact( ContactVO contact );
}
