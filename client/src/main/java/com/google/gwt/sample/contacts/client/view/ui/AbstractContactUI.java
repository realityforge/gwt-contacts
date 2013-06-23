package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.sample.contacts.client.data_type.ContactsFactory;
import com.google.gwt.sample.contacts.client.data_type.contacts.ContactDTO;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Widget;
import javax.inject.Inject;

public abstract class AbstractContactUI
  extends Composite
{
  @UiField
  HasText _firstName;
  @UiField
  HasText _lastName;
  @UiField
  HasText _emailAddress;
  @Inject
  ContactsFactory _factory;

  private ContactDTO _contact;

  public final void setContact( final ContactDTO contact )
  {
    if( null != contact )
    {
      _contact = contact;
      _firstName.setText( _contact.getFirstName() );
      _lastName.setText( _contact.getLastName() );
      _emailAddress.setText( _contact.getEmailAddress() );
    }
    else
    {
      _firstName.setText( "" );
      _lastName.setText( "" );
      _emailAddress.setText( "" );
    }
  }

  protected final void copyBackContact()
  {
    final ContactDTO newContact = _factory.createContactDTO().as();
    newContact.setID( null != _contact ? _contact.getID() : null );
    newContact.setType( null != _contact ? _contact.getType() : null );
    newContact.setFirstName( _firstName.getText() );
    newContact.setLastName( _lastName.getText() );
    newContact.setEmailAddress( _emailAddress.getText() );
    _contact = newContact;
  }

  protected final ContactDTO getContact()
  {
    return _contact;
  }

  public final Widget asWidget()
  {
    return this;
  }
}
