package com.google.gwt.sample.contacts.client.shell.desktop;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.shell.ApplicationShell;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.SimplePanel;
import javax.inject.Inject;

@SuppressWarnings( { "UnusedDeclaration" } )
public class DesktopShell
    implements ApplicationShell
{
  private PlaceHistoryHandler _placeHistoryHandler;
  private ActivityMapper _mapper;
  private EventBus _eventBus;

  @Inject
  public DesktopShell( final PlaceHistoryHandler placeHistoryHandler, final ActivityMapper mapper, final EventBus eventBus )
  {
    _placeHistoryHandler = placeHistoryHandler;
    _mapper = mapper;
    _eventBus = eventBus;
  }

  public void activate()
  {
    // Force the creation of the ActivityManager
    final ActivityManager activityManager = new ActivityManager( _mapper, _eventBus );
    final SimplePanel display = new SimplePanel();
    activityManager.setDisplay( display );

    RootPanel.get().add( display );

    // Goes to place represented on URL or default place
    _placeHistoryHandler.handleCurrentHistory();
  }
}
