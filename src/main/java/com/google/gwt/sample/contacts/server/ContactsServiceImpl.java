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

  public Contact addContact( Contact contact )
  {
    return contacts.addContact( contact );
  }

  public Contact updateContact( Contact contact )
  {
    return contacts.updateContact( contact );
  }

  public Boolean deleteContact( String id )
  {
    return contacts.deleteContact( id );
  }

  public ArrayList<ContactDetails> deleteContacts( ArrayList<String> ids )
  {
    return contacts.deleteContacts( ids );
  }

  public ArrayList<ContactDetails> getContactDetails()
  {
    return contacts.getContactDetails();
  }

  public Contact getContact( String id )
  {
    return contacts.getContact( id );
  }
}
