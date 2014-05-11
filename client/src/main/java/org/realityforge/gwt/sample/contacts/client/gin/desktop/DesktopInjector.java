package org.realityforge.gwt.sample.contacts.client.gin.desktop;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import org.realityforge.gwt.sample.contacts.client.application.desktop.DesktopApplication;
import org.realityforge.gwt.sample.contacts.client.gin.ApplicationInjector;
import org.realityforge.gwt.sample.contacts.client.gin.ContactClientModule;
import org.realityforge.gwt.sample.contacts.client.ioc.ContactsGwtRpcServicesModule;

@GinModules( { ContactClientModule.class, ContactsGwtRpcServicesModule.class, DesktopModule.class } )
public interface DesktopInjector
    extends Ginjector, ApplicationInjector
{
  DesktopApplication getShell();
}
