package org.realityforge.gwt.sample.contacts.test.util;

import org.realityforge.guiceyloops.server.Flushable;
import org.realityforge.guiceyloops.server.ServerTestModule;
import org.realityforge.gwt.sample.contacts.server.service.ContactsEJB;
import org.realityforge.gwt.sample.contacts.server.service.ContactsService;

public class ContactsTestModule
  extends ServerTestModule
{
  public ContactsTestModule( final Flushable flushable )
  {
    super( flushable );
  }

  @Override
  protected void configure()
  {
    super.configure();
    bind( ContactsService.class ).to( ContactsEJB.class );
  }
}
