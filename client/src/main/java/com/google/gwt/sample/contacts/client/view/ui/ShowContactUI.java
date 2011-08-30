package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.client.view.ShowContactView;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Widget;

public class ShowContactUI
    extends AbstractContactUI
    implements ShowContactView
{
  interface Binder extends UiBinder<Widget, ShowContactUI> {}

  private static final Binder uiBinder = GWT.create( Binder.class );

  @UiField
  Button _editButton;

  @UiField
  Button _closeButton;

  private Presenter _presenter;

  public ShowContactUI()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  @UiHandler( "_editButton" )
  void onEditButtonClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      _presenter.onEditButtonClicked( getContact() );
    }
  }

  @UiHandler( "_closeButton" )
  void onReturnToListButtonClicked( final ClickEvent event )
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
