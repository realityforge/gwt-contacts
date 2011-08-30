package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.sample.contacts.client.shell.phone.PhoneShell;

@GinModules( { ContactClientModule.class, ContactsServicesGinModule.class } )
public interface PhoneInjector
    extends Ginjector, ApplicationInjector
{
  PhoneShell getShell();
}
