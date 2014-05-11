package org.realityforge.gwt.sample.contacts.server.service;

import org.junit.Test;
import org.realityforge.gwt.sample.contacts.test.util.AbstractContactsTest;
import static org.junit.Assert.*;

public class ContactsEJBTest
  extends AbstractContactsTest
{
  @Test
  public void testContactsEJB()
  {
    assertEquals( 22, s( ContactsService.class ).getContactDetails().size() );
  }
}
