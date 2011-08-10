package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

public class EditContactUI
    extends Composite
    implements EditContactView
{
  interface Binder extends UiBinder<Widget, EditContactUI> {}

  private static final Binder uiBinder = GWT.create( Binder.class );

  @UiField
  TextBox _firstName;
  @UiField
  TextBox _lastName;
  @UiField
  TextBox _emailAddress;
  @UiField
  Button _saveButton;
  @UiField
  Button _cancelButton;

  private Presenter _presenter;
  private Contact _contact;

  public EditContactUI()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  @UiHandler( "_saveButton" )
  void onSaveButtonClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      _contact.setFirstName( _firstName.getValue() );
      _contact.setLastName( _lastName.getValue() );
      _contact.setEmailAddress( _emailAddress.getValue() );
      _presenter.onSaveButtonClicked( _contact );
    }
  }

  @UiHandler( "_cancelButton" )
  void onCancelButtonClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      _presenter.onCancelButtonClicked();
    }
  }

  public void setPresenter( final Presenter presenter )
  {
    _presenter = presenter;
  }

  public void setContact( final Contact contact )
  {
    _contact = contact;
    _firstName.setValue( _contact.getFirstName() );
    _lastName.setValue( _contact.getLastName() );
    _emailAddress.setValue( _contact.getEmailAddress() );
  }

  public Widget asWidget()
  {
    return this;
  }
}
