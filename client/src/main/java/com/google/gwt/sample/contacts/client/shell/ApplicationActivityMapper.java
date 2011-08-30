package com.google.gwt.sample.contacts.client.shell;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceController;
import com.google.gwt.sample.contacts.client.activity.EditContactActivity;
import com.google.gwt.sample.contacts.client.activity.ListContactsActivity;
import com.google.gwt.sample.contacts.client.activity.ShowContactActivity;
import com.google.gwt.sample.contacts.client.event.AddContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.AddContactCancelledEventHandler;
import com.google.gwt.sample.contacts.client.event.AddContactEvent;
import com.google.gwt.sample.contacts.client.event.AddContactEventHandler;
import com.google.gwt.sample.contacts.client.event.ContactClosedEvent;
import com.google.gwt.sample.contacts.client.event.ContactClosedEventHandler;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEventHandler;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEventHandler;
import com.google.gwt.sample.contacts.client.event.EditContactEvent;
import com.google.gwt.sample.contacts.client.event.EditContactEventHandler;
import com.google.gwt.sample.contacts.client.event.ShowContactEvent;
import com.google.gwt.sample.contacts.client.event.ShowContactEventHandler;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.client.place.ShowContactPlace;
import javax.inject.Inject;
import javax.inject.Provider;

/**
 * ApplicationActivityMapper associates each Place with its corresponding {@link Activity}.
 */
public class ApplicationActivityMapper
    implements ActivityMapper
{
  private final PlaceController _placeController;
  private final EventBus _eventBus;
  private final Provider<ListContactsActivity> _listContactsPresenter;
  private final Provider<EditContactActivity> _editContactPresenter;
  private final Provider<ShowContactActivity> _showContactPresenter;

  @Inject
  public ApplicationActivityMapper( final PlaceController placeController,
                                    final EventBus eventBus,
                                    final Provider<ListContactsActivity> contactsPresenter,
                                    final Provider<EditContactActivity> editContactPresenter,
                                    final Provider<ShowContactActivity> showContactPresenter )
  {
    _placeController = placeController;
    _eventBus = eventBus;
    _listContactsPresenter = contactsPresenter;
    _editContactPresenter = editContactPresenter;
    _showContactPresenter = showContactPresenter;
    bind();
  }

  @Override
  public Activity getActivity( final Place place )
  {
    if( place instanceof ListContactsPlace )
    {
      return _listContactsPresenter.get();
    }
    else if( place instanceof ShowContactPlace )
    {
      return _showContactPresenter.get().withPlace( (ShowContactPlace) place );
    }
    else if( place instanceof AddContactPlace )
    {
      return _editContactPresenter.get().withPlace( (AddContactPlace) place );
    }
    else if( place instanceof EditContactPlace )
    {
      return _editContactPresenter.get().withPlace( (EditContactPlace) place );
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
