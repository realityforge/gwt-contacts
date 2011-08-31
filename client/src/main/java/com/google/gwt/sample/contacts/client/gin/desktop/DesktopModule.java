package com.google.gwt.sample.contacts.client.gin.desktop;

import com.google.gwt.inject.client.AbstractGinModule;
import com.google.gwt.sample.contacts.client.application.desktop.DetailRegionActivityMapper;
import com.google.gwt.sample.contacts.client.application.desktop.MasterRegionActivityMapper;
import com.google.gwt.sample.contacts.client.view.DesktopShellView;
import com.google.gwt.sample.contacts.client.view.ui.DesktopShellUI;
import javax.inject.Singleton;

public class DesktopModule
    extends AbstractGinModule
{
  protected void configure()
  {
    bind( DesktopShellView.class ).to( DesktopShellUI.class ).in( Singleton.class );
    bind( MasterRegionActivityMapper.class ).in( Singleton.class );
    bind( DetailRegionActivityMapper.class ).in( Singleton.class );
  }
}
