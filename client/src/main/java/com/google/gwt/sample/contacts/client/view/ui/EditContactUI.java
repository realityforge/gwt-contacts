package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.client.view.EditContactView;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Widget;

public class EditContactUI
    extends AbstractContactUI
    implements EditContactView
{
  interface Binder extends UiBinder<Widget, EditContactUI> {}

  private static final Binder uiBinder = GWT.create( Binder.class );

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
      copyBackContact();
      _presenter.onSaveButtonClicked( getContact() );
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
}
