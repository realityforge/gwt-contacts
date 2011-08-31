package com.google.gwt.sample.contacts.client.application.desktop;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.place.shared.Place;
import com.google.gwt.sample.contacts.client.activity.ListContactsActivity;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.place.ShowContactPlace;
import javax.inject.Inject;
import javax.inject.Provider;

public class MasterRegionActivityMapper
    implements ActivityMapper
{
  private final Provider<ListContactsActivity> _listContactsPresenter;

  @Inject
  public MasterRegionActivityMapper( final Provider<ListContactsActivity> contactsPresenter )
  {
    _listContactsPresenter = contactsPresenter;
  }

  @Override
  public Activity getActivity( final Place place )
  {
    final ListContactsActivity activity = _listContactsPresenter.get();
    if( place instanceof ShowContactPlace )
    {
      // And highlight contact
    }
    else if( place instanceof AddContactPlace )
    {
      // And highlight contact
    }
    else if( place instanceof EditContactPlace )
    {
      // And highlight contact
    }
    return activity;
  }
}
