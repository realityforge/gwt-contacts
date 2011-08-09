package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.view.EditContactView;
import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.inject.Inject;

public class EditContactActivity
  extends AbstractActivity
  implements EditContactView.Presenter
{
  private static final Logger LOG = Logger.getLogger( "EditContact" );

  private Contact _contact;
  private final ContactsServiceAsync _rpcService;
  private final EventBus _eventBus;
  private final EditContactView _view;

  @Inject
  public EditContactActivity( final ContactsServiceAsync rpcService,
                              final EventBus eventBus,
                              final EditContactView view )
  {
    _rpcService = rpcService;
    _eventBus = eventBus;
    _view = view;
  }

  public EditContactActivity withPlace( final EditContactPlace place )
  {
    LOG.log( Level.INFO, "Editing contact: " + place.getId() );
    _rpcService.getContact( place.getId(), new AsyncCallback<Contact>()
    {
      public void onSuccess( final Contact contact )
      {
        _contact = contact;
        EditContactActivity.this._view.getFirstName().setValue( _contact.getFirstName() );
        EditContactActivity.this._view.getLastName().setValue( _contact.getLastName() );
        EditContactActivity.this._view.getEmailAddress().setValue( _contact.getEmailAddress() );
      }

      public void onFailure( final Throwable caught )
      {
        LOG.log( Level.SEVERE, "Error retrieving contact", caught );
        Window.alert( "Error retrieving contact" );
      }
    } );
    return this;
  }

  public EditContactActivity withPlace( final AddContactPlace place )
  {
    LOG.log( Level.INFO, "Creating contact" );
    _contact = new Contact();
    return this;
  }

  @Override
  public void start( final AcceptsOneWidget panel, final EventBus eventBus )
  {
    _view.setPresenter( this );
    panel.setWidget( _view.asWidget() );
  }

  public void onSaveButtonClicked()
  {
    _contact.setFirstName( _view.getFirstName().getValue() );
    _contact.setLastName( _view.getLastName().getValue() );
    _contact.setEmailAddress( _view.getEmailAddress().getValue() );

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

  public void onCancelButtonClicked()
  {
    _eventBus.fireEvent( new EditContactCancelledEvent() );
  }
}
