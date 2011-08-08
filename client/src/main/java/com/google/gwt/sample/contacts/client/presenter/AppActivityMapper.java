package com.google.gwt.sample.contacts.client.presenter;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceController;
import com.google.gwt.sample.contacts.client.event.AddContactEvent;
import com.google.gwt.sample.contacts.client.event.AddContactEventHandler;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEventHandler;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEventHandler;
import com.google.gwt.sample.contacts.client.event.EditContactEvent;
import com.google.gwt.sample.contacts.client.event.EditContactEventHandler;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;

/** AppActivityMapper associates each Place with its corresponding {@link Activity}. */
public class AppActivityMapper
  implements ActivityMapper
{
  private final PlaceController _placeController;
  private final ContactsServiceAsync _rpcService;
  private final EventBus _eventBus;

  public AppActivityMapper( final PlaceController placeController,
                            final ContactsServiceAsync rpcService,
                            final EventBus eventBus )
  {
    _placeController = placeController;
    _rpcService = rpcService;
    _eventBus = eventBus;
    bind();
  }

  @Override
  public Activity getActivity( final Place place )
  {
    if ( place instanceof ListContactsPlace )
    {
      return new ContactsPresenter( _rpcService, _eventBus );
    }
    else if ( place instanceof AddContactPlace )
    {
      return new EditContactPresenter( _rpcService, _eventBus, null );
    }
    else if ( place instanceof EditContactPlace )
    {
      return new EditContactPresenter( _rpcService, _eventBus, ( (EditContactPlace) place ).getId() );
    }
    return null;
  }

  private void bind()
  {
    _eventBus.addHandler( AddContactEvent.TYPE, new AddContactEventHandler()
    {
      public void onAddContact( final AddContactEvent event )
      {
        _placeController.goTo( new AddContactPlace() );
      }
    } );

    _eventBus.addHandler( EditContactEvent.TYPE, new EditContactEventHandler()
    {
      public void onEditContact( final EditContactEvent event )
      {
        _placeController.goTo( new EditContactPlace( event.getId() ) );
      }
    } );

    _eventBus.addHandler( EditContactCancelledEvent.TYPE, new EditContactCancelledEventHandler()
    {
      public void onEditContactCancelled( final EditContactCancelledEvent event )
      {
        _placeController.goTo( new ListContactsPlace() );
      }
    } );

    _eventBus.addHandler( ContactUpdatedEvent.TYPE, new ContactUpdatedEventHandler()
    {
      public void onContactUpdated( final ContactUpdatedEvent event )
      {
        _placeController.goTo( new ListContactsPlace() );
      }
    } );
  }
}
