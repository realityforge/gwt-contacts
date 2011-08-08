package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.event.shared.SimpleEventBus;
import com.google.gwt.inject.client.AbstractGinModule;
import com.google.gwt.place.shared.PlaceController;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.place.shared.PlaceHistoryMapper;
import com.google.gwt.sample.contacts.client.place.AppPlaceHistoryMapper;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.client.presenter.AppActivityMapper;
import com.google.gwt.sample.contacts.client.presenter.ContactsPresenter;
import com.google.gwt.sample.contacts.client.presenter.EditContactPresenter;
import com.google.gwt.sample.contacts.client.view.ListContactsView;
import com.google.gwt.sample.contacts.client.view.ListContactsUI;
import com.google.gwt.sample.contacts.client.view.EditContactUI;
import com.google.gwt.sample.contacts.client.view.EditContactView;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.inject.Provides;
import javax.inject.Singleton;

public class ContactClientModule
  extends AbstractGinModule
{
  protected void configure()
  {
    bind( EventBus.class ).to( SimpleEventBus.class ).in( Singleton.class );
    bind( SimplePanel.class ).in( Singleton.class );
    bind( PlaceHistoryMapper.class ).to( AppPlaceHistoryMapper.class ).in( Singleton.class );
    bind( ActivityMapper.class ).to( AppActivityMapper.class ).in( Singleton.class );

    bind( ListContactsView.class ).to( ListContactsUI.class ).in( Singleton.class );
    bind( EditContactView.class ).to( EditContactUI.class ).in( Singleton.class );
    bind( ContactsPresenter.class );
    bind( EditContactPresenter.class );
  }

  // None of the components below are Gin enabled so lets create factory methods for them

  @Provides
  @Singleton
  public PlaceHistoryHandler getHistoryHandler( final PlaceController placeController,
                                                final PlaceHistoryMapper historyMapper,
                                                final EventBus eventBus )
  {
    final PlaceHistoryHandler historyHandler = new PlaceHistoryHandler( historyMapper );
    historyHandler.register( placeController, eventBus, new ListContactsPlace() );
    return historyHandler;
  }

  @Provides
  @Singleton
  public PlaceController getPlaceController( final EventBus eventBus )
  {
    return new PlaceController( eventBus );
  }

  @Provides
  @Singleton
  public ActivityManager getActivityManager( final ActivityMapper mapper,
                                             final EventBus eventBus,
                                             final SimplePanel display )
  {
    final ActivityManager activityManager = new ActivityManager( mapper, eventBus );
    activityManager.setDisplay( display );
    return activityManager;
  }
}