package com.google.gwt.sample.contacts.server.service;

import com.google.gwt.sample.contacts.server.entity.Contact;
import com.google.gwt.sample.contacts.server.entity.dao.ContactDAO;
import com.google.gwt.sample.contacts.shared.ContactDetailsVO;
import com.google.gwt.sample.contacts.shared.ContactVO;
import java.util.ArrayList;
import javax.annotation.Nonnull;
import javax.ejb.EJB;
import javax.ejb.Stateless;

@Stateless( name = ContactsService.EJB_NAME )
public class ContactsEJB
  implements ContactsService
{
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

  @EJB
  private ContactDAO _repository;

  @Nonnull
  public ContactVO createOrUpdateContact( @Nonnull final ContactVO dto )
  {
    if ( null == dto.getId() )
    {
      final Contact contact = new Contact();
      updatePersistentFromDTO( dto, contact );
      _repository.persist( contact );
      return toContactDTO( contact );
    }
    else
    {
      final Contact contact = findByID( dto.getId() );
      updatePersistentFromDTO( dto, contact );
      return toContactDTO( contact );
    }
  }

  public void deleteContacts( @Nonnull java.util.ArrayList<java.lang.String> ids )
  {
    for ( final String id : ids )
    {
      _repository.remove( findByID( id ) );
    }
  }

  @Nonnull
  public ArrayList<ContactDetailsVO> getContactDetails()
  {
    initContactsIfRequired();
    final ArrayList<ContactDetailsVO> contactDetails = new ArrayList<ContactDetailsVO>();
    for ( final Contact contact : _repository.findAll() )
    {
      contactDetails.add( toLightWeightContactDTO( contact ) );
    }

    return contactDetails;
  }

  @Nonnull
  public ContactVO getContact( @Nonnull final String id )
  {
    return toContactDTO( findByID( id ) );
  }

  private ContactVO toContactDTO( final Contact result )
  {
    return new ContactVO( String.valueOf( result.getID() ), result.getFirstName(), result.getLastName(),
                          result.getEmailAddress() );
  }

  private ContactDetailsVO toLightWeightContactDTO( final Contact contact )
  {
    return new ContactDetailsVO( String.valueOf( contact.getID() ),
                                 contact.getFirstName() + " " + contact.getLastName() );
  }

  private Contact findByID( final String id )
  {
    return _repository.findByID( Integer.parseInt( id ) );
  }

  private void updatePersistentFromDTO( final ContactVO contact, final Contact persistent )
  {
    persistent.setFirstName( contact.getFirstName() );
    persistent.setLastName( contact.getLastName() );
    persistent.setEmailAddress( contact.getEmailAddress() );
  }

  private void initContactsIfRequired()
  {
    if ( 0 == _repository.findAll().size() )
    {
      for ( int i = 0; i < FIRST_NAMES.length && i < LAST_NAMES.length && i < EMAILS.length; ++i )
      {
        final ContactVO dto = new ContactVO( null, FIRST_NAMES[ i ], LAST_NAMES[ i ], EMAILS[ i ] );
        createOrUpdateContact( dto );
      }
    }
  }
}
