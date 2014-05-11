package org.realityforge.gwt.sample.contacts.client.application;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.PlaceController;
import javax.annotation.Nonnull;
import javax.inject.Inject;
import org.realityforge.gwt.sample.contacts.client.event.AddContactCancelledEvent;
import org.realityforge.gwt.sample.contacts.client.event.AddContactEvent;
import org.realityforge.gwt.sample.contacts.client.event.ContactClosedEvent;
import org.realityforge.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import org.realityforge.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import org.realityforge.gwt.sample.contacts.client.event.EditContactEvent;
import org.realityforge.gwt.sample.contacts.client.event.ShowContactEvent;
import org.realityforge.gwt.sample.contacts.client.place.AddContactPlace;
import org.realityforge.gwt.sample.contacts.client.place.EditContactPlace;
import org.realityforge.gwt.sample.contacts.client.place.ListContactsPlace;
import org.realityforge.gwt.sample.contacts.client.place.ShowContactPlace;

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
    _eventBus.addHandler( AddContactEvent.TYPE, new AddContactEvent.Handler()
    {
      public void onAddContact( final AddContactEvent event )
      {
        _placeController.goTo( new AddContactPlace() );
      }
    } );

    _eventBus.addHandler( EditContactEvent.TYPE, new EditContactEvent.Handler()
    {
      public void onEditContact( @Nonnull final EditContactEvent event )
      {
        _placeController.goTo( new EditContactPlace( event.getID() ) );
      }
    } );

    _eventBus.addHandler( ShowContactEvent.TYPE, new ShowContactEvent.Handler()
    {
      public void onShowContact( @Nonnull final ShowContactEvent event )
      {
        _placeController.goTo( new ShowContactPlace( event.getID() ) );
      }
    } );

    _eventBus.addHandler( EditContactCancelledEvent.TYPE, new EditContactCancelledEvent.Handler()
    {
      public void onEditContactCancelled( @Nonnull final EditContactCancelledEvent event )
      {
        _placeController.goTo( new ShowContactPlace( event.getID() ) );
      }
    } );

    _eventBus.addHandler( AddContactCancelledEvent.TYPE, new AddContactCancelledEvent.Handler()
    {
      public void onAddContactCancelled( @Nonnull final AddContactCancelledEvent event )
      {
        _placeController.goTo( new ListContactsPlace() );
      }
    } );

    _eventBus.addHandler( ContactClosedEvent.TYPE, new ContactClosedEvent.Handler()
    {
      public void onContactClosed( @Nonnull final ContactClosedEvent event )
      {
        _placeController.goTo( new ListContactsPlace() );
      }
    } );

    _eventBus.addHandler( ContactUpdatedEvent.TYPE, new ContactUpdatedEvent.Handler()
    {
      public void onContactUpdated( @Nonnull final ContactUpdatedEvent event )
      {
        _placeController.goTo( new ShowContactPlace( event.getID() ) );
      }
    } );
  }
}
