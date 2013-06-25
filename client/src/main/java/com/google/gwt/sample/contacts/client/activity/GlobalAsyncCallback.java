package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;

/**
 * Callback invoked on completion of every job
 */
public class GlobalAsyncCallback
  implements AsyncCallback
{
  @Override
  public void onFailure( final Throwable caught )
  {
    Window.alert( "Error communicating with the server" );
  }

  @Override
  public void onSuccess( final Object result )
  {
  }
}
