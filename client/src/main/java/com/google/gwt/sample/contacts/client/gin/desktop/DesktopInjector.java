package com.google.gwt.sample.contacts.client.gin.desktop;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.sample.contacts.client.application.desktop.DesktopApplication;
import com.google.gwt.sample.contacts.client.gin.ApplicationInjector;
import com.google.gwt.sample.contacts.client.gin.ContactClientModule;
import com.google.gwt.sample.contacts.client.ioc.ContactsGwtServicesModule;

@GinModules( { ContactClientModule.class, ContactsGwtServicesModule.class, DesktopModule.class } )
public interface DesktopInjector
    extends Ginjector, ApplicationInjector
{
  DesktopApplication getShell();
}
