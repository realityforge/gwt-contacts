package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.sample.contacts.shared.ContactVO;
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

  private ContactVO _contact;

  public final void setContact( final ContactVO contact )
  {
    _contact = contact;
    _firstName.setText( _contact.getFirstName() );
    _lastName.setText( _contact.getLastName() );
    _emailAddress.setText( _contact.getEmailAddress() );
  }

  protected final void copyBackContact()
  {
    _contact.setFirstName( _firstName.getText()  );
    _contact.setLastName( _lastName.getText() );
    _contact.setEmailAddress( _emailAddress.getText() );
  }

  protected final ContactVO getContact()
  {
    return _contact;
  }

  public final Widget asWidget()
  {
    return this;
  }
}
