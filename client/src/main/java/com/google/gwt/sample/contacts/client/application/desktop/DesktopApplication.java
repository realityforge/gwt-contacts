package com.google.gwt.sample.contacts.client.application.desktop;

import com.google.gwt.activity.shared.ActivityManager;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.PlaceHistoryHandler;
import com.google.gwt.sample.contacts.client.application.Application;
import com.google.gwt.sample.contacts.client.application.ApplicationNavigator;
import com.google.gwt.sample.contacts.client.view.DesktopShellView;
import com.google.gwt.user.client.ui.RootLayoutPanel;
import javax.inject.Inject;

@SuppressWarnings( { "UnusedDeclaration" } )
public class DesktopApplication
    implements Application
{
  private final DesktopShellView _shell;
  private final ApplicationNavigator _navigator;
  private final PlaceHistoryHandler _placeHistoryHandler;
  private final DetailRegionActivityMapper _detailRegionMapper;
  private final MasterRegionActivityMapper _masterRegionMapper;
  private final EventBus _eventBus;

  @Inject
  public DesktopApplication( final DesktopShellView shell,
                             final ApplicationNavigator navigator,
                             final PlaceHistoryHandler placeHistoryHandler,
                             final DetailRegionActivityMapper detailRegionMapper,
                             final MasterRegionActivityMapper masterRegionMapper,
                             final EventBus eventBus )
  {
    _shell = shell;
    _navigator = navigator;
    _placeHistoryHandler = placeHistoryHandler;
    _detailRegionMapper = detailRegionMapper;
    _masterRegionMapper = masterRegionMapper;
    _eventBus = eventBus;
  }

  public void activate()
  {
    _navigator.activate();

    new ActivityManager( _masterRegionMapper, _eventBus ).setDisplay( _shell.getMasterRegion() );
    new ActivityManager( _detailRegionMapper, _eventBus ).setDisplay( _shell.getDetailRegion() );

    RootLayoutPanel.get().add( _shell );

    // Goes to place represented on URL or default place
    _placeHistoryHandler.handleCurrentHistory();
  }
}
