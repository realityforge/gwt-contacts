package com.google.gwt.sample.contacts.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.sample.contacts.client.gin.ContactGinjector;
import com.google.gwt.sample.contacts.client.gin.TokenManager;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.rpc.RpcTokenException;
import com.google.gwt.user.client.rpc.ServiceDefTarget;
import com.google.gwt.user.client.rpc.XsrfToken;
import com.google.gwt.user.client.rpc.XsrfTokenService;
import com.google.gwt.user.client.rpc.XsrfTokenServiceAsync;
import com.google.gwt.user.client.ui.RootPanel;

public final class ContactsEntryPoint
  implements EntryPoint
{
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
        catch ( final RpcTokenException e )
        {
          // Can be thrown for several reasons:
          //   - duplicate session cookie, which may be a sign of a cookie
          //     overwrite attack
          //   - XSRF token cannot be generated because session cookie isn't
          //     present
        }
        catch ( Throwable e )
        {
          // unexpected
        }
        Window.alert( "Error generating security token. Please reload page." );
      }

      public void onSuccess( final XsrfToken xsrfToken )
      {
        TokenManager.setXsrfToken( xsrfToken );
        startupApplication();
      }
    } );
  }

  private void startupApplication()
  {
    final ContactGinjector injector = GWT.create( ContactGinjector.class );

    // Force the creation of the ActivityManager
    injector.getActivityManager();

    RootPanel.get().add( injector.getMainPanel() );
    // Goes to place represented on URL or default place
    injector.getPlaceHistoryHandler().handleCurrentHistory();
  }
}
