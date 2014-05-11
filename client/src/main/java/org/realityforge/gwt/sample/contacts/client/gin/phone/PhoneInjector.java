package org.realityforge.gwt.sample.contacts.client.gin.phone;

import com.google.gwt.inject.client.GinModules;
import com.google.gwt.inject.client.Ginjector;
import org.realityforge.gwt.sample.contacts.client.application.phone.PhoneApplication;
import org.realityforge.gwt.sample.contacts.client.gin.ApplicationInjector;
import org.realityforge.gwt.sample.contacts.client.gin.ContactClientModule;
import org.realityforge.gwt.sample.contacts.client.ioc.ContactsGwtRpcServicesModule;

@GinModules( { ContactClientModule.class, ContactsGwtRpcServicesModule.class, PhoneModule.class } )
public interface PhoneInjector
    extends Ginjector, ApplicationInjector
{
  PhoneApplication getShell();
}
