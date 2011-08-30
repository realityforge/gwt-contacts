package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.sample.contacts.client.application.desktop.DesktopApplication;

@GinModules( { ContactClientModule.class, ContactsServicesGinModule.class } )
public interface DesktopInjector
    extends Ginjector, ApplicationInjector
{
  DesktopApplication getShell();
}
