package com.google.gwt.sample.contacts.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.sample.contacts.client.gin.ContactGinjector;
import com.google.gwt.sample.contacts.client.gin.ContactsServicesGinModule;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.rpc.RpcTokenException;
import com.google.gwt.user.client.rpc.ServiceDefTarget;
import com.google.gwt.user.client.rpc.XsrfToken;
import com.google.gwt.user.client.rpc.XsrfTokenService;
import com.google.gwt.user.client.rpc.XsrfTokenServiceAsync;
import com.google.gwt.user.client.ui.RootPanel;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class Contacts
    implements EntryPoint
{
  private static final Logger LOG = Logger.getLogger( "EntryPoint" );

  public void onModuleLoad()
  {
    final XsrfTokenServiceAsync xsrf = (XsrfTokenServiceAsync) GWT.create( XsrfTokenService.class );
    //noinspection GwtSetServiceEntryPointCalls
    ( (ServiceDefTarget) xsrf ).setServiceEntryPoint( GWT.getHostPageBaseURL() + "xsrf" );
    // Do something like the following if you are not using container based security
    //com.google.gwt.user.client.Cookies.setCookie( "JSESSIONID", "Any value you like for the XSRF Token creation" );
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
          LOG.log( Level.SEVERE, "Problem generating RPC token: Possible causes: duplicate session cookie which may be a sign of a cookie overwrite attack or XSRF token cannot be generated because session cookie isn't present", e  );
        }
        catch( final Throwable e )
        {
          // unexpected
          LOG.log( Level.SEVERE, "Unexpected problem generating security token", e  );
        }
        Window.alert( "Error generating security token. Please reload page." );
      }

      public void onSuccess( final XsrfToken xsrfToken )
      {
        ContactsServicesGinModule.initialize( GWT.getModuleName(), xsrfToken );
        startupApplication();
      }
    } );
  }

  private void startupApplication()
  {
    /* Add handlers, setup activities */
    GWT.setUncaughtExceptionHandler( new GWT.UncaughtExceptionHandler()
    {
      public void onUncaughtException( final Throwable e )
      {
        LOG.log( Level.SEVERE, "Unexpected problem with application", e  );
      }
    } );

    final ContactGinjector injector = GWT.create( ContactGinjector.class );

    // Force the creation of the ActivityManager
    injector.getActivityManager();

    RootPanel.get().add( injector.getMainPanel() );
    // Goes to place represented on URL or default place
    injector.getPlaceHistoryHandler().handleCurrentHistory();
  }
}
