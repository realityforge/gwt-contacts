package com.google.gwt.sample.contacts.client.application.phone;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.place.shared.Place;
import com.google.gwt.sample.contacts.client.activity.EditContactActivity;
import com.google.gwt.sample.contacts.client.activity.ListContactsActivity;
import com.google.gwt.sample.contacts.client.activity.ShowContactActivity;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.client.place.ShowContactPlace;
import javax.inject.Inject;
import javax.inject.Provider;

/**
 * ApplicationActivityMapper associates each Place with its corresponding {@link Activity}.
 */
public class PhoneActivityMapper
    implements ActivityMapper
{
  private final Provider<ListContactsActivity> _listContactsPresenter;
  private final Provider<EditContactActivity> _editContactPresenter;
  private final Provider<ShowContactActivity> _showContactPresenter;

  @Inject
  public PhoneActivityMapper( final Provider<ListContactsActivity> contactsPresenter,
                              final Provider<EditContactActivity> editContactPresenter,
                              final Provider<ShowContactActivity> showContactPresenter )
  {
    _listContactsPresenter = contactsPresenter;
    _editContactPresenter = editContactPresenter;
    _showContactPresenter = showContactPresenter;
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
}
