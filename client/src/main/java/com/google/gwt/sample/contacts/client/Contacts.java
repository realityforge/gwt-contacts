package com.google.gwt.sample.contacts.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.sample.contacts.client.gin.ContactsServicesGinModule;
import com.google.gwt.sample.contacts.client.gin.InjectorWrapper;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.rpc.RpcTokenException;
import com.google.gwt.user.client.rpc.ServiceDefTarget;
import com.google.gwt.user.client.rpc.XsrfToken;
import com.google.gwt.user.client.rpc.XsrfTokenService;
import com.google.gwt.user.client.rpc.XsrfTokenServiceAsync;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class Contacts
    implements com.google.gwt.core.client.EntryPoint
{
  private static final Logger LOG = Logger.getLogger( "EntryPoint" );

  public void onModuleLoad()
  {
    final XsrfTokenServiceAsync xsrf = (XsrfTokenServiceAsync) GWT.create( XsrfTokenService.class );
    //noinspection GwtSetServiceEntryPointCalls
    ( (ServiceDefTarget) xsrf ).setServiceEntryPoint( GWT.getHostPageBaseURL() + "xsrf" );
    xsrf.getNewXsrfToken( new AsyncCallback<XsrfToken>()
    {
      public void onFailure( final Throwable caught )
      {
        try
        {
          throw caught;
        }
        catch( final RpcTokenException e )
        {
          // Can be thrown for several reasons:
          //   - duplicate session cookie, which may be a sign of a cookie overwrite attack
          //   - XSRF token cannot be generated because session cookie isn't present
          LOG.log( Level.SEVERE, "Problem generating RPC token: Possible causes: duplicate session cookie which may be a sign of a cookie overwrite attack or XSRF token cannot be generated because session cookie isn't present", e );

        }
        catch( final Throwable e )
        {
          LOG.log( Level.SEVERE, "Unexpected problem generating security token", e );
        }
        Window.alert( "Error generating security token. Please reload page." );
      }

      public void onSuccess( final XsrfToken xsrfToken )
      {
        try
        {
          ContactsServicesGinModule.initialize( GWT.getModuleName(), xsrfToken );
          startupApplication();
        }
        catch( final Exception e )
        {
          LOG.log( Level.SEVERE, "Unexpected problem initializing the application", e );
          Window.alert( "Error " + e );
        }
      }
    } );
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
