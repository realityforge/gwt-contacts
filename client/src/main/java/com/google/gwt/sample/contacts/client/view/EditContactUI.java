package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasValue;
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

  public EditContactUI()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  @UiHandler( "_saveButton" )
  void onSaveButtonClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      _presenter.onSaveButtonClicked();
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

  public HasValue<String> getFirstName()
  {
    return _firstName;
  }

  public HasValue<String> getLastName()
  {
    return _lastName;
  }

  public HasValue<String> getEmailAddress()
  {
    return _emailAddress;
  }

  public Widget asWidget()
  {
    return this;
  }
}
