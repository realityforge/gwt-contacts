package com.google.gwt.sample.contacts.server.service;

import com.google.gwt.sample.contacts.server.entity.Contact;
import com.google.gwt.sample.contacts.server.entity.ContactType;
import com.google.gwt.sample.contacts.server.entity.dao.ContactDAO;
import com.google.gwt.sample.contacts.server.entity.dao.ContactTypeDAO;
import com.google.gwt.sample.contacts.shared.data_type.ContactDTO;
import com.google.gwt.sample.contacts.shared.data_type.ContactDetailsDTO;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.Nonnull;
import javax.ejb.EJB;
import javax.ejb.Stateless;

@Stateless( name = ContactsService.EJB_NAME )
public class ContactsEJB
    implements ContactsService
{
  private static final String[] CONTACT_TYPES =
      new String[] { "Home", "Work", "Mobile", "Satellite" };

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
  private ContactDAO _contactDAO;

  @EJB
  private ContactTypeDAO _contactTypeDAO;

  @Override
  @Nonnull
  public ContactDTO createOrUpdateContact( @Nonnull final ContactDTO dto )
  {
    if( null == dto.getID() )
    {
      final Contact contact = new Contact();
      updatePersistentFromDTO( dto, contact );
      _contactDAO.persist( contact );
      return toContactDTO( contact );
    }
    else
    {
      final Contact contact = findByID( dto.getID() );
      updatePersistentFromDTO( dto, contact );
      return toContactDTO( contact );
    }
  }

  @Override
  public void deleteContacts( @Nonnull java.util.List<java.lang.String> ids )
  {
    for( final String id : ids )
    {
      _contactDAO.remove( findByID( id ) );
    }
  }

  @Override
  @Nonnull
  public List<ContactDetailsDTO> getContactDetails()
  {
    initContactsIfRequired();
    final ArrayList<ContactDetailsDTO> contactDetails = new ArrayList<ContactDetailsDTO>();
    for( final Contact contact : _contactDAO.findAll() )
    {
      contactDetails.add( toLightWeightContactDTO( contact ) );
    }

    return contactDetails;
  }

  @Override
  @Nonnull
  public ContactDTO getContact( @Nonnull final String id )
  {
    return toContactDTO( findByID( id ) );
  }

  private ContactDTO toContactDTO( final Contact result )
  {
    return new ContactDTO( String.valueOf( result.getID() ),
                          result.getContactType().getName(),
                          result.getFirstName(),
                          result.getLastName(),
                          result.getEmailAddress() );
  }

  private ContactDetailsDTO toLightWeightContactDTO( final Contact contact )
  {
    return new ContactDetailsDTO( String.valueOf( contact.getID() ),
                                 contact.getContactType().getName(),
                                 contact.getFirstName() + " " + contact.getLastName() );
  }

  private Contact findByID( final String id )
  {
    return _contactDAO.findByID( Integer.parseInt( id ) );
  }

  private ContactType findOrCreateTypeByName( final String name )
  {
    final ContactType type = _contactTypeDAO.findByName( name );
    if( null != type )
    {
      return type;
    }
    else
    {
      final ContactType ct = new ContactType();
      ct.setName( name );
      ct.setRenderCode( name );
      _contactTypeDAO.persist( ct );
      return ct;
    }
  }

  private void updatePersistentFromDTO( final ContactDTO contact, final Contact persistent )
  {
    String type = contact.getType();
    type = ( null == type || "".equals( type ) ) ? CONTACT_TYPES[ 0 ] : type;
    persistent.setContactType( findOrCreateTypeByName( type ) );
    persistent.setFirstName( contact.getFirstName() );
    persistent.setLastName( contact.getLastName() );
    persistent.setEmailAddress( contact.getEmailAddress() );
  }

  private void initContactsIfRequired()
  {
    if( 0 == _contactDAO.findAll().size() )
    {
      for( int i = 0; i < FIRST_NAMES.length && i < LAST_NAMES.length && i < EMAILS.length; ++i )
      {
        final ContactDTO dto = new ContactDTO( null,
                                             CONTACT_TYPES[ i % CONTACT_TYPES.length ],
                                             FIRST_NAMES[ i ],
                                             LAST_NAMES[ i ],
                                             EMAILS[ i ] );
        createOrUpdateContact( dto );
      }
    }
  }
}
