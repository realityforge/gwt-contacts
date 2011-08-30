package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.core.client.GWT;

@SuppressWarnings( { "UnusedDeclaration" } )
public class PhoneInjectorWrapper
    implements InjectorWrapper
{
  public ApplicationInjector getInjector()
  {
    return GWT.create( PhoneInjector.class );
  }
}
