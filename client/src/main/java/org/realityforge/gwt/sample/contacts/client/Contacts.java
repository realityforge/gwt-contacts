package org.realityforge.gwt.sample.contacts.client;

import com.google.gwt.core.client.GWT;
import org.realityforge.gwt.sample.contacts.client.gin.InjectorWrapper;
import org.realityforge.gwt.sample.contacts.client.ioc.ContactsGwtRpcServicesModule;
import com.google.gwt.user.client.Window;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class Contacts
    implements com.google.gwt.core.client.EntryPoint
{
  private static final Logger LOG = Logger.getLogger( "EntryPoint" );

  public void onModuleLoad()
  {
    try
    {
      ContactsGwtRpcServicesModule.initialize( GWT.getModuleName() );
      startupApplication();
    }
    catch ( final Exception e )
    {
      LOG.log( Level.SEVERE, "Unexpected problem initializing the application", e );
      Window.alert( "Error " + e );
    }
  }

  private void startupApplication()
  {
    GWT.setUncaughtExceptionHandler( new GWT.UncaughtExceptionHandler()
    {
      public void onUncaughtException( final Throwable e )
      {
        LOG.log( Level.SEVERE, "Unexpected problem with application", e );
      }
    } );
    final InjectorWrapper injector = GWT.create( InjectorWrapper.class );
    injector.getInjector().getShell().activate();
  }
}
