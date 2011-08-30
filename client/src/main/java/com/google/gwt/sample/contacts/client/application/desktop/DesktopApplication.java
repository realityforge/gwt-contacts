package com.google.gwt.sample.contacts.client.application.desktop;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.application.Application;
import com.google.gwt.sample.contacts.client.view.DesktopShellView;
import com.google.gwt.user.client.ui.RootLayoutPanel;
import javax.inject.Inject;

@SuppressWarnings( { "UnusedDeclaration" } )
public class DesktopApplication
    implements Application
{
  private final DesktopShellView _shell;
  private final PlaceHistoryHandler _placeHistoryHandler;
  private final ActivityMapper _mapper;
  private final EventBus _eventBus;

  @Inject
  public DesktopApplication( final DesktopShellView shell,
                             final PlaceHistoryHandler placeHistoryHandler,
                             final ActivityMapper mapper,
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
    activityManager.setDisplay( _shell.getMasterRegion() );

    RootLayoutPanel.get().add( _shell );

    // Goes to place represented on URL or default place
    _placeHistoryHandler.handleCurrentHistory();
  }
}
