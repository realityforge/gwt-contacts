package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.sample.contacts.client.application.phone.PhoneApplication;

@GinModules( { ContactClientModule.class, ContactsServicesGinModule.class } )
public interface PhoneInjector
    extends Ginjector, ApplicationInjector
{
  PhoneApplication getShell();
}
