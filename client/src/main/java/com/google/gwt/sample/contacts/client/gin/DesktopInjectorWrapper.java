package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.core.client.GWT;

public class DesktopInjectorWrapper
    implements InjectorWrapper
{
  public ApplicationInjector getInjector()
  {
    return GWT.create( DesktopInjector.class );
  }
}
