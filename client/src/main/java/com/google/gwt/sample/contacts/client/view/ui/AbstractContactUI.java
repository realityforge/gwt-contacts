package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.sample.contacts.shared.data_type.ContactDTO;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Widget;

public abstract class AbstractContactUI
  extends Composite
{
  @UiField
  HasText _firstName;
  @UiField
  HasText _lastName;
  @UiField
  HasText _emailAddress;

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
    _contact = new ContactDTO( null != _contact ? _contact.getID() : null,
                               null != _contact ? _contact.getType() : null,
                               _firstName.getText(),
                               _lastName.getText(),
                               _emailAddress.getText() );
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
