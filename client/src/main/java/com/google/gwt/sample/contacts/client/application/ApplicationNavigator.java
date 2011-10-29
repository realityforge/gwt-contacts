package com.google.gwt.sample.contacts.client.application;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.PlaceController;
import com.google.gwt.sample.contacts.client.event.contacts.AddContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.contacts.AddContactCancelledEventHandler;
import com.google.gwt.sample.contacts.client.event.contacts.AddContactEvent;
import com.google.gwt.sample.contacts.client.event.contacts.AddContactEventHandler;
import com.google.gwt.sample.contacts.client.event.contacts.ContactClosedEvent;
import com.google.gwt.sample.contacts.client.event.contacts.ContactClosedEventHandler;
import com.google.gwt.sample.contacts.client.event.contacts.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.contacts.ContactUpdatedEventHandler;
import com.google.gwt.sample.contacts.client.event.contacts.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.contacts.EditContactCancelledEventHandler;
import com.google.gwt.sample.contacts.client.event.contacts.EditContactEvent;
import com.google.gwt.sample.contacts.client.event.contacts.EditContactEventHandler;
import com.google.gwt.sample.contacts.client.event.contacts.ShowContactEvent;
import com.google.gwt.sample.contacts.client.event.contacts.ShowContactEventHandler;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.client.place.ShowContactPlace;
import javax.inject.Inject;

/**
 * The class is responsible for listening to application events and navigating to
 * correct place as a result of events.
 */
public class ApplicationNavigator
{
  private final PlaceController _placeController;
  private final EventBus _eventBus;

  @Inject
  public ApplicationNavigator( final PlaceController placeController,
                               final EventBus eventBus )
  {
    _placeController = placeController;
    _eventBus = eventBus;
  }

  public void activate()
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
        _placeController.goTo( new EditContactPlace( event.getID() ) );
      }
    } );

    _eventBus.addHandler( ShowContactEvent.TYPE, new ShowContactEventHandler()
    {
      public void onShowContact( final ShowContactEvent event )
      {
        _placeController.goTo( new ShowContactPlace( event.getID() ) );
      }
    } );

    _eventBus.addHandler( EditContactCancelledEvent.TYPE, new EditContactCancelledEventHandler()
    {
      public void onEditContactCancelled( final EditContactCancelledEvent event )
      {
        _placeController.goTo( new ShowContactPlace( event.getID() ) );
      }
    } );

    _eventBus.addHandler( AddContactCancelledEvent.TYPE, new AddContactCancelledEventHandler()
    {
      public void onAddContactCancelled( final AddContactCancelledEvent event )
      {
        _placeController.goTo( new ListContactsPlace() );
      }
    } );

    _eventBus.addHandler( ContactClosedEvent.TYPE, new ContactClosedEventHandler()
    {
      public void onContactClosed( final ContactClosedEvent event )
      {
        _placeController.goTo( new ListContactsPlace() );
      }
    } );

    _eventBus.addHandler( ContactUpdatedEvent.TYPE, new ContactUpdatedEventHandler()
    {
      public void onContactUpdated( final ContactUpdatedEvent event )
      {
        _placeController.goTo( new ShowContactPlace( event.getID() ) );
      }
    } );
  }
}
