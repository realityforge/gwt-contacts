package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import java.util.ArrayList;
import javax.ejb.Stateless;
import javax.persistence.TypedQuery;

@Stateless( name = ContactsEJB.EJB_NAME )
public class ContactsEJB
  implements LocalContacts
{
  public static final String EJB_NAME = "Core.ContactsEJB";

  private static final String[] FIRST_NAMES = new String[]{
    "Hollie", "Emerson", "Healy", "Brigitte", "Elba", "Claudio",
    "Dena", "Christina", "Gail", "Orville", "Rae", "Mildred",
    "Candice", "Louise", "Emilio", "Geneva", "Heriberto", "Bulrush",
    "Abigail", "Chad", "Terry", "Bell" };

  private static final String[] LAST_NAMES = new String[]{
    "Voss", "Milton", "Colette", "Cobb", "Lockhart", "Engle",
    "Pacheco", "Blake", "Horton", "Daniel", "Childers", "Starnes",
    "Carson", "Kelchner", "Hutchinson", "Underwood", "Rush", "Bouchard",
    "Louis", "Andrews", "English", "Snedden" };

  private static final String[] EMAILS = new String[]{
    "mark@example.com", "hollie@example.com", "boticario@example.com",
    "emerson@example.com", "healy@example.com", "brigitte@example.com",
    "elba@example.com", "claudio@example.com", "dena@example.com",
    "brasilsp@example.com", "parker@example.com", "derbvktqsr@example.com",
    "qetlyxxogg@example.com", "antenas_sul@example.com",
    "cblake@example.com", "gailh@example.com", "orville@example.com",
    "post_master@example.com", "rchilders@example.com", "buster@example.com",
    "user31065@example.com", "ftsgeolbx@example.com" };

  @javax.persistence.PersistenceContext( unitName = "contacts" )
  private javax.persistence.EntityManager _em;

  public Contact createOrUpdateContact( final Contact dto )
  {
    if ( null == dto.getId() )
    {
      final ContactBean contact = new ContactBean();
      updatePersistentFromDTO( dto, contact );
      _em.persist( contact );
    }
    else
    {
      final ContactBean contact = findByID( dto.getId() );
      updatePersistentFromDTO( dto, contact );
    }
    return dto;
  }

  public void deleteContacts( final ArrayList<String> ids )
  {
    for ( final String id : ids )
    {
      _em.remove( findByID( id ) );
    }
  }

  public ArrayList<ContactDetails> getContactDetails()
  {
    initContactsIfRequired();
    final TypedQuery<ContactBean> query = _em.createNamedQuery( ContactBean.findAll, ContactBean.class );

    final ArrayList<ContactDetails> contactDetails = new ArrayList<ContactDetails>();
    for ( final ContactBean contact : query.getResultList() )
    {
      contactDetails.add( toLightWeightContactDTO( contact ) );
    }

    return contactDetails;
  }

  public Contact getContact( final String id )
  {
    return toContactDTO( findByID( id ) );
  }

  private Contact toContactDTO( final ContactBean result )
  {
    return new Contact( String.valueOf( result.getID() ), result.getFirstName(), result.getLastName(),
                        result.getEmailAddress() );
  }

  private ContactDetails toLightWeightContactDTO( final ContactBean contact )
  {
    return new ContactDetails( String.valueOf( contact.getID() ), contact.getFullName() );
  }

  private ContactBean findByID( final String id )
  {
    return findByID( Integer.parseInt( id ) );
  }

  private ContactBean findByID( final Integer id )
  {
    final javax.persistence.TypedQuery<ContactBean> query = _em.createNamedQuery( ContactBean.findByID,
                                                                                 ContactBean.class );
    query.setParameter( "ID", id );
    return query.getSingleResult();
  }

  private void updatePersistentFromDTO( final Contact contact, final ContactBean persistent )
  {
    persistent.setFirstName( contact.getFirstName() );
    persistent.setLastName( contact.getLastName() );
    persistent.setEmailAddress( contact.getEmailAddress() );
  }

  private void initContactsIfRequired()
  {
    if ( 0 == _em.createNamedQuery( ContactBean.findAll, ContactBean.class ).getResultList().size() )
    {
      for ( int i = 0; i < FIRST_NAMES.length && i < LAST_NAMES.length && i < EMAILS.length; ++i )
      {
        final Contact dto = new Contact( null, FIRST_NAMES[ i ], LAST_NAMES[ i ], EMAILS[ i ] );
        createOrUpdateContact( dto );
      }
    }
  }
}
