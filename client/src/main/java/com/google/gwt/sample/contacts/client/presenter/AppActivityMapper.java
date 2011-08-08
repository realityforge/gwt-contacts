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
import javax.inject.Inject;
import javax.inject.Provider;

/** AppActivityMapper associates each Place with its corresponding {@link Activity}. */
public class AppActivityMapper
  implements ActivityMapper
{
  private final PlaceController _placeController;
  private final EventBus _eventBus;
  private final Provider<ContactsPresenter> _listContactsPresenter;
  private final Provider<EditContactPresenter> _editContactPresenter;

  @Inject
  public AppActivityMapper( final PlaceController placeController,
                            final EventBus eventBus,
                            final Provider<ContactsPresenter> contactsPresenter,
                            final Provider<EditContactPresenter> editContactPresenter )
  {
    _placeController = placeController;
    _eventBus = eventBus;
    _listContactsPresenter = contactsPresenter;
    _editContactPresenter = editContactPresenter;
    bind();
  }

  @Override
  public Activity getActivity( final Place place )
  {
    if ( place instanceof ListContactsPlace )
    {
      return _listContactsPresenter.get();
    }
    else if ( place instanceof AddContactPlace )
    {
      return _editContactPresenter.get().withPlace( (AddContactPlace) place );
    }
    else if ( place instanceof EditContactPlace )
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
