package com.google.gwt.sample.contacts.client.presenter;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.shared.HandlerManager;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.view.EditContactView;
import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.HasWidgets;

public class EditContactPresenter
  implements EditContactView.Presenter
{
  private Contact _contact;
  private final ContactsServiceAsync _rpcService;
  private final HandlerManager _eventBus;
  private final EditContactView _display;

  public EditContactPresenter( final ContactsServiceAsync rpcService,
                               final HandlerManager eventBus,
                               final EditContactView display )
  {
    _rpcService = rpcService;
    _eventBus = eventBus;
    _contact = new Contact();
    _display = display;
    bind();
  }

  public EditContactPresenter( final ContactsServiceAsync rpcService,
                               final HandlerManager eventBus,
                               final EditContactView display,
                               final String id )
  {
    this._rpcService = rpcService;
    this._eventBus = eventBus;
    this._display = display;
    bind();

    rpcService.getContact( id, new AsyncCallback<Contact>()
    {
      public void onSuccess( final Contact result )
      {
        _contact = result;
        EditContactPresenter.this._display.getFirstName().setValue( _contact.getFirstName() );
        EditContactPresenter.this._display.getLastName().setValue( _contact.getLastName() );
        EditContactPresenter.this._display.getEmailAddress().setValue( _contact.getEmailAddress() );
      }

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error retrieving contact" );
      }
    } );

  }

  public void bind()
  {
    this._display.getSaveButton().addClickHandler( new ClickHandler()
    {
      public void onClick( final ClickEvent event )
      {
        doSave();
      }
    } );

    this._display.getCancelButton().addClickHandler( new ClickHandler()
    {
      public void onClick( final ClickEvent event )
      {
        _eventBus.fireEvent( new EditContactCancelledEvent() );
      }
    } );
  }

  public void go( final HasWidgets container )
  {
    container.clear();
    container.add( _display.asWidget() );
  }

  private void doSave()
  {
    _contact.setFirstName( _display.getFirstName().getValue() );
    _contact.setLastName( _display.getLastName().getValue() );
    _contact.setEmailAddress( _display.getEmailAddress().getValue() );

    _rpcService.createOrUpdateContact( _contact, new AsyncCallback<Contact>()
    {
      public void onSuccess( final Contact result )
      {
        _eventBus.fireEvent( new ContactUpdatedEvent( result ) );
      }

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error updating contact" );
      }
    } );
  }
}
