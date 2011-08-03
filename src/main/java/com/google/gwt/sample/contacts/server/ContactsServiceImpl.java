package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.client.ContactsService;
import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import java.util.ArrayList;
import javax.ejb.EJB;

@SuppressWarnings( "serial" )
public class ContactsServiceImpl
  extends RemoteServiceServlet
  implements ContactsService
{
  @EJB
  private LocalContacts contacts;

  public Contact createOrUpdateContact( final Contact contact )
  {
    return contacts.createOrUpdateContact( contact );
  }

  public void deleteContacts( final ArrayList<String> ids )
  {
    contacts.deleteContacts( ids );
  }

  public ArrayList<ContactDetails> getContactDetails()
  {
    return contacts.getContactDetails();
  }

  public Contact getContact( final String id )
  {
    return contacts.getContact( id );
  }
}
