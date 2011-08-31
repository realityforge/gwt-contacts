package com.google.gwt.sample.contacts.client.gin.phone;

import com.google.gwt.core.client.GWT;
import com.google.gwt.sample.contacts.client.gin.ApplicationInjector;
import com.google.gwt.sample.contacts.client.gin.InjectorWrapper;

@SuppressWarnings( { "UnusedDeclaration" } )
public class PhoneInjectorWrapper
    implements InjectorWrapper
{
  public ApplicationInjector getInjector()
  {
    return GWT.create( PhoneInjector.class );
  }
}
