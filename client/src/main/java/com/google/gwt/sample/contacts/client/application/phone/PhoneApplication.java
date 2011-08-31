package com.google.gwt.sample.contacts.client.application.phone;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.application.Application;
import com.google.gwt.sample.contacts.client.view.PhoneShellView;
import com.google.gwt.user.client.ui.RootPanel;
import javax.inject.Inject;

@SuppressWarnings( { "UnusedDeclaration" } )
public class PhoneApplication
    implements Application
{
  private final PhoneShellView _shell;
  private final PlaceHistoryHandler _placeHistoryHandler;
  private final PhoneActivityMapper _mapper;
  private final EventBus _eventBus;

  @Inject
  public PhoneApplication( final PhoneShellView shell,
                           final PlaceHistoryHandler placeHistoryHandler,
                           final PhoneActivityMapper mapper,
                           final EventBus eventBus )
  {
    _shell = shell;
    _placeHistoryHandler = placeHistoryHandler;
    _mapper = mapper;
    _eventBus = eventBus;
  }

  public void activate()
  {
    // Force the creation of the ActivityManager
    final ActivityManager activityManager = new ActivityManager( _mapper, _eventBus );
    activityManager.setDisplay( _shell.getRegion() );

    RootPanel.get().add( _shell.asWidget() );

    // Goes to place represented on URL or default place
    _placeHistoryHandler.handleCurrentHistory();
  }
}
