package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import java.util.ArrayList;
import java.util.HashMap;
import javax.annotation.PostConstruct;
import javax.ejb.Singleton;
import javax.ejb.Stateless;

@Singleton
public class ContactsEJB
  implements LocalContacts
{
  private static final String[] firstNameData = new String[]{
    "Hollie", "Emerson", "Healy", "Brigitte", "Elba", "Claudio",
    "Dena", "Christina", "Gail", "Orville", "Rae", "Mildred",
    "Candice", "Louise", "Emilio", "Geneva", "Heriberto", "Bulrush",
    "Abigail", "Chad", "Terry", "Bell" };

  private final String[] lastNameData = new String[]{
    "Voss", "Milton", "Colette", "Cobb", "Lockhart", "Engle",
    "Pacheco", "Blake", "Horton", "Daniel", "Childers", "Starnes",
    "Carson", "Kelchner", "Hutchinson", "Underwood", "Rush", "Bouchard",
    "Louis", "Andrews", "English", "Snedden" };

  private final String[] emailData = new String[]{
    "mark@example.com", "hollie@example.com", "boticario@example.com",
    "emerson@example.com", "healy@example.com", "brigitte@example.com",
    "elba@example.com", "claudio@example.com", "dena@example.com",
    "brasilsp@example.com", "parker@example.com", "derbvktqsr@example.com",
    "qetlyxxogg@example.com", "antenas_sul@example.com",
    "cblake@example.com", "gailh@example.com", "orville@example.com",
    "post_master@example.com", "rchilders@example.com", "buster@example.com",
    "user31065@example.com", "ftsgeolbx@example.com" };

  private final HashMap<String, Contact> contacts = new HashMap<String, Contact>();

  @PostConstruct
  private void initContacts()
  {
    for ( int i = 0; i < firstNameData.length && i < lastNameData.length && i < emailData.length; ++i )
    {
      final Contact contact =
        new Contact( String.valueOf( i ), firstNameData[ i ], lastNameData[ i ], emailData[ i ] );
      contacts.put( contact.getId(), contact );
    }
  }

  public Contact addContact( final Contact contact )
  {
    contact.setId( String.valueOf( contacts.size() ) );
    contacts.put( contact.getId(), contact );
    return contact;
  }

  public Contact updateContact( final Contact contact )
  {
    contacts.remove( contact.getId() );
    contacts.put( contact.getId(), contact );
    return contact;
  }

  public Boolean deleteContact( final String id )
  {
    contacts.remove( id );
    return true;
  }

  public ArrayList<ContactDetails> deleteContacts( final ArrayList<String> ids )
  {
    for ( final String id : ids )
    {
      deleteContact( id );
    }

    return getContactDetails();
  }

  public ArrayList<ContactDetails> getContactDetails()
  {
    ArrayList<ContactDetails> contactDetails = new ArrayList<ContactDetails>();

    for ( final String s : contacts.keySet() )
    {
      final Contact contact = contacts.get( s );
      contactDetails.add( contact.getLightWeightContact() );
    }

    return contactDetails;
  }

  public Contact getContact( final String id )
  {
    return contacts.get( id );
  }
}
