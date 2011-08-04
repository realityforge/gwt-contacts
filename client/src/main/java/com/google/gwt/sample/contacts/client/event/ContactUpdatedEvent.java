package com.google.gwt.sample.contacts.client.event;

import com.google.gwt.event.shared.GwtEvent;
import com.google.gwt.sample.contacts.shared.Contact;

public class ContactUpdatedEvent
  extends GwtEvent<ContactUpdatedEventHandler>
{
  public static final Type<ContactUpdatedEventHandler> TYPE = new Type<ContactUpdatedEventHandler>();
  private final Contact _updatedContact;

  public ContactUpdatedEvent( final Contact updatedContact )
  {
    _updatedContact = updatedContact;
  }

  public Contact getUpdatedContact()
  {
    return _updatedContact;
  }


  @Override
  public Type<ContactUpdatedEventHandler> getAssociatedType()
  {
    return TYPE;
  }

  @Override
  protected void dispatch( final ContactUpdatedEventHandler handler )
  {
    handler.onContactUpdated( this );
  }
}
