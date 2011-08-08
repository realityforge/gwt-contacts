package com.google.gwt.sample.contacts.client;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.event.shared.SimpleEventBus;
import com.google.gwt.place.shared.PlaceController;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.place.AppPlaceHistoryMapper;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.client.presenter.AppActivityMapper;
import com.google.gwt.sample.contacts.shared.ContactsService;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;
import com.google.gwt.user.client.ui.Panel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;

public final class Contacts
  implements EntryPoint
{
  public void onModuleLoad()
  {
    final ContactGinjector injector = GWT.create( ContactGinjector.class );

    // This just here to force the instantiation of activity manager
    injector.getActivityManager();
    RootPanel.get().add( injector.getMainPanel() );
    // Goes to place represented on URL or default place
    injector.getPlaceHistoryHandler().handleCurrentHistory();
  }
}
