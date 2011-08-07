package com.google.gwt.sample.contacts.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.event.shared.HandlerManager;
import com.google.gwt.event.shared.SimpleEventBus;
import com.google.gwt.place.shared.PlaceController;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.place.AppPlaceHistoryMapper;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;
import com.google.gwt.sample.contacts.shared.ContactsService;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;
import com.google.gwt.user.client.ui.RootPanel;

public final class Contacts
    implements EntryPoint
{
  public void onModuleLoad()
  {
    final EventBus eventBus = new SimpleEventBus();
    final PlaceController placeController = new PlaceController( eventBus );

    // Start PlaceHistoryHandler with our PlaceHistoryMapper
    final AppPlaceHistoryMapper historyMapper = GWT.create( AppPlaceHistoryMapper.class );
    final PlaceHistoryHandler historyHandler = new PlaceHistoryHandler( historyMapper );
    historyHandler.register( placeController, eventBus, new ListContactsPlace() );

    final ContactsServiceAsync rpcService = GWT.create( ContactsService.class );
    final AppController appViewer = new AppController( rpcService, new HandlerManager( null ) );
    appViewer.go( RootPanel.get() );
  }
}
