package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.inject.client.AsyncProvider;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import javax.inject.Inject;

public abstract class ActivityProxy<A extends Activity> implements Activity
{
  private final AsyncProvider<A> _activityProvider;
  private A _activity;
  private boolean _isCancelled;

  @Inject
  public ActivityProxy( final AsyncProvider<A> activityProvider )
  {
    _activityProvider = activityProvider;
  }

  @Override
  public String mayStop()
  {
    if( _activity != null )
    {
      return _activity.mayStop();
    }
    return null;
  }

  @Override
  public final void onCancel()
  {
    _isCancelled = true;
    if( _activity != null )
    {
      _activity.onCancel();
    }
  }

  @Override
  public void onStop()
  {
    if( _activity != null )
    {
      _activity.onStop();
    }
  }

  @Override
  public void start( final AcceptsOneWidget panel, final EventBus eventBus )
  {

    //if activity already there start it...
    if( _activity != null )
    {
      _activity.start( panel, eventBus );

      //otherwise load it...
    }
    else
    {
      _activityProvider.get( new AsyncCallback<A>()
      {

        @Override
        public void onFailure( Throwable caught )
        {
          // TODO or FIXME if you want me to do anything
        }

        @Override
        public void onSuccess( A result )
        {

          _activity = result;
          if( !_isCancelled )
          {
            _activity.start( panel, eventBus );
          }
        }

      } );
    }

  }

}
