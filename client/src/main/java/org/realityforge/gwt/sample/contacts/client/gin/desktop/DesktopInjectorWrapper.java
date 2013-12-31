package org.realityforge.gwt.sample.contacts.client.gin.desktop;

import com.google.gwt.core.client.GWT;
import org.realityforge.gwt.sample.contacts.client.gin.ApplicationInjector;
import org.realityforge.gwt.sample.contacts.client.gin.InjectorWrapper;

public class DesktopInjectorWrapper
    implements InjectorWrapper
{
  public ApplicationInjector getInjector()
  {
    return GWT.create( DesktopInjector.class );
  }
}
