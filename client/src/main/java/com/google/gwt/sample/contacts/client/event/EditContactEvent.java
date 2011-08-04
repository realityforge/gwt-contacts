package com.google.gwt.sample.contacts.client.event;

import com.google.gwt.event.shared.GwtEvent;

public class EditContactEvent
  extends GwtEvent<EditContactEventHandler>
{
  public static final Type<EditContactEventHandler> TYPE = new Type<EditContactEventHandler>();
  private final String _id;

  public EditContactEvent( final String id )
  {
    _id = id;
  }

  public String getId()
  {
    return _id;
  }

  @Override
  public Type<EditContactEventHandler> getAssociatedType()
  {
    return TYPE;
  }

  @Override
  protected void dispatch( final EditContactEventHandler handler )
  {
    handler.onEditContact( this );
  }
}
