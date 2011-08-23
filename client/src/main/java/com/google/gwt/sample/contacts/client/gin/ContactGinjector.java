package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.ContactsServicesGinModule;
import com.google.gwt.user.client.ui.SimplePanel;

@GinModules( { ContactClientModule.class, ContactsServicesGinModule.class } )
public interface ContactGinjector
  extends Ginjector
{
  ActivityManager getActivityManager();

  PlaceHistoryHandler getPlaceHistoryHandler();

  SimplePanel getMainPanel();
}
