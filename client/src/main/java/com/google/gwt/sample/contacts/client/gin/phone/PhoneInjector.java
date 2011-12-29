package com.google.gwt.sample.contacts.client.gin.phone;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import com.google.gwt.sample.contacts.client.application.phone.PhoneApplication;
import com.google.gwt.sample.contacts.client.gin.ApplicationInjector;
import com.google.gwt.sample.contacts.client.gin.ContactClientModule;
import com.google.gwt.sample.contacts.client.ioc.ContactsGwtServicesModule;

@GinModules( { ContactClientModule.class, ContactsGwtServicesModule.class, PhoneModule.class } )
public interface PhoneInjector
    extends Ginjector, ApplicationInjector
{
  PhoneApplication getShell();
}
