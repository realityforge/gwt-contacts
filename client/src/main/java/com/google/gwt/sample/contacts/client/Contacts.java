package com.google.gwt.sample.contacts.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.sample.contacts.client.gin.ContactGinjector;
import com.google.gwt.user.client.ui.RootPanel;

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
