package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.sample.contacts.client.view.ui.DesktopShell;

@GinModules( { ContactClientModule.class, ContactsServicesGinModule.class } )
public interface DesktopInjector
    extends Ginjector, ApplicationInjector
{
  DesktopShell getShell();
}
