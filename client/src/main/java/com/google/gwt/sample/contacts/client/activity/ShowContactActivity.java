package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.sample.contacts.client.event.contacts.ContactClosedEvent;
import com.google.gwt.sample.contacts.client.event.contacts.EditContactEvent;
import com.google.gwt.sample.contacts.client.place.ShowContactPlace;
import com.google.gwt.sample.contacts.client.view.ShowContactView;
import com.google.gwt.sample.contacts.shared.contacts.GwtContactsServiceAsync;
import com.google.gwt.sample.contacts.shared.data_type.ContactDTO;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.inject.Inject;

public class ShowContactActivity
    extends AbstractActivity
    implements ShowContactView.Presenter
{
  private static final Logger LOG = Logger.getLogger( "ShowContact" );

  private final GwtContactsServiceAsync _rpcService;
  private final EventBus _eventBus;
  private final ShowContactView _view;

  private String _contactID;

  @Inject
  public ShowContactActivity( final GwtContactsServiceAsync rpcService,
                              final EventBus eventBus,
                              final ShowContactView view )
  {
    _rpcService = rpcService;
    _eventBus = eventBus;
    _view = view;
  }

  public ShowContactActivity withPlace( final ShowContactPlace place )
  {
    _contactID = place.getId();
    LOG.log( Level.INFO, "Showing contact: " + _contactID );
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

  @Override
  public void start( final AcceptsOneWidget panel, final EventBus eventBus )
  {
    _view.setPresenter( this );
    panel.setWidget( _view.asWidget() );
  }

  public void onEditButtonClicked( final ContactDTO contact )
  {
    _eventBus.fireEvent( new EditContactEvent( contact.getID() ) );
  }

  public void onCancelButtonClicked()
  {
    _eventBus.fireEvent( new ContactClosedEvent( _contactID ) );
  }
}
