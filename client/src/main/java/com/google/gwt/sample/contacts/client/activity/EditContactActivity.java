package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.sample.contacts.client.event.contacts.AddContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.contacts.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.contacts.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.view.EditContactView;
import com.google.gwt.sample.contacts.shared.contacts.GwtContactsServiceAsync;
import com.google.gwt.sample.contacts.shared.data_type.ContactDTO;
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

  private final GwtContactsServiceAsync _rpcService;
  private final EventBus _eventBus;
  private final EditContactView _view;

  private String _contactID;

  @Inject
  public EditContactActivity( final GwtContactsServiceAsync rpcService,
                              final EventBus eventBus,
                              final EditContactView view )
  {
    _rpcService = rpcService;
    _eventBus = eventBus;
    _view = view;
  }

  public EditContactActivity withPlace( final EditContactPlace place )
  {
    _contactID = place.getId();
    LOG.log( Level.INFO, "Editing contact: " + _contactID );
    _rpcService.getContact( _contactID, new AsyncCallback<ContactDTO>()
    {
      public void onSuccess( final ContactDTO contact )
      {
        _view.setContact( contact );
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
    _contactID = null;
    LOG.log( Level.INFO, "Creating contact" );
    _view.setContact( null );
    return this;
  }

  @Override
  public void start( final AcceptsOneWidget panel, final EventBus eventBus )
  {
    _view.setPresenter( this );
    panel.setWidget( _view.asWidget() );
  }

  public void onSaveButtonClicked( final ContactDTO contact )
  {
    LOG.log( Level.INFO, "onSaveButtonClicked() = " + contact );
    _rpcService.createOrUpdateContact( contact, new AsyncCallback<ContactDTO>()
    {
      public void onSuccess( final ContactDTO result )
      {
        _eventBus.fireEvent( new ContactUpdatedEvent( result.getID() ) );
      }

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error updating contact" );
      }
    } );
  }

  public void onCancelButtonClicked()
  {
    LOG.log( Level.INFO, "onCancelButtonClicked() = " + _contactID );
    if( null == _contactID )
    {
      _eventBus.fireEvent( new AddContactCancelledEvent() );

    }
    else
    {
      _eventBus.fireEvent( new EditContactCancelledEvent( _contactID ) );
    }
  }
}
