package com.google.gwt.sample.contacts.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.core.client.RunAsyncCallback;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.event.shared.HandlerManager;
import com.google.gwt.sample.contacts.client.common.ContactsColumnDefinitionsImpl;
import com.google.gwt.sample.contacts.client.event.AddContactEvent;
import com.google.gwt.sample.contacts.client.event.AddContactEventHandler;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEventHandler;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEventHandler;
import com.google.gwt.sample.contacts.client.event.EditContactEvent;
import com.google.gwt.sample.contacts.client.event.EditContactEventHandler;
import com.google.gwt.sample.contacts.client.presenter.ContactsPresenter;
import com.google.gwt.sample.contacts.client.presenter.EditContactPresenter;
import com.google.gwt.sample.contacts.client.presenter.Presenter;
import com.google.gwt.sample.contacts.client.view.ContactsViewUI;
import com.google.gwt.sample.contacts.client.view.EditContactView;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.ui.HasWidgets;

public class AppController
  implements Presenter, ValueChangeHandler<String>
{
  private final HandlerManager _eventBus;
  private final ContactsServiceAsync _rpcService;
  private HasWidgets _container;
  private ContactsViewUI<ContactDetails> _contactsView;
  private EditContactView _editContactView;

  public AppController( final ContactsServiceAsync rpcService, final HandlerManager eventBus )
  {
    _eventBus = eventBus;
    _rpcService = rpcService;
    bind();
  }

  private void bind()
  {
    History.addValueChangeHandler( this );

    _eventBus.addHandler( AddContactEvent.TYPE,
                         new AddContactEventHandler()
                         {
                           public void onAddContact( final AddContactEvent event )
                           {
                             doAddNewContact();
                           }
                         } );

    _eventBus.addHandler( EditContactEvent.TYPE,
                         new EditContactEventHandler()
                         {
                           public void onEditContact( final EditContactEvent event )
                           {
                             doEditContact( event.getId() );
                           }
                         } );

    _eventBus.addHandler( EditContactCancelledEvent.TYPE,
                         new EditContactCancelledEventHandler()
                         {
                           public void onEditContactCancelled( final EditContactCancelledEvent event )
                           {
                             doEditContactCancelled();
                           }
                         } );

    _eventBus.addHandler( ContactUpdatedEvent.TYPE,
                         new ContactUpdatedEventHandler()
                         {
                           public void onContactUpdated( final ContactUpdatedEvent event )
                           {
                             doContactUpdated();
                           }
                         } );
  }

  private void doAddNewContact()
  {
    History.newItem( "add" );
  }

  private void doEditContact( final String id )
  {
    History.newItem( "edit", false );
    final Presenter presenter = new EditContactPresenter( _rpcService, _eventBus, new EditContactView(), id );
    presenter.go( _container );
  }

  private void doEditContactCancelled()
  {
    History.newItem( "list" );
  }

  private void doContactUpdated()
  {
    History.newItem( "list" );
  }

  public void go( final HasWidgets container )
  {
    this._container = container;

    if ( "".equals( History.getToken() ) )
    {
      History.newItem( "list" );
    }
    else
    {
      History.fireCurrentHistoryState();
    }
  }

  public void onValueChange( final ValueChangeEvent<String> event )
  {
    final String token = event.getValue();

    if ( token != null )
    {
      if ( token.equals( "list" ) )
      {
        GWT.runAsync( new RunAsyncCallback()
        {
          public void onFailure( final Throwable caught )
          {
          }

          public void onSuccess()
          {
            // lazily initialize our views, and keep them around to be reused
            //
            if ( _contactsView == null )
            {
              _contactsView = new ContactsViewUI<ContactDetails>();

            }
            new ContactsPresenter( _rpcService, _eventBus, _contactsView, ContactsColumnDefinitionsImpl.getInstance() )
              .go( _container );
          }
        } );
      }
      else if ( token.equals( "add" ) || token.equals( "edit" ) )
      {
        GWT.runAsync( new RunAsyncCallback()
        {
          public void onFailure( final Throwable caught )
          {
          }

          public void onSuccess()
          {
            // lazily initialize our views, and keep them around to be reused
            //
            if ( _editContactView == null )
            {
              _editContactView = new EditContactView();

            }
            new EditContactPresenter( _rpcService, _eventBus, _editContactView).go( _container );
          }
        } );
      }
    }
  }
}
