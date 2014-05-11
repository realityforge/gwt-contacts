package org.realityforge.gwt.sample.contacts.server.service;

import org.realityforge.gwt.sample.contacts.test.util.AbstractContactsTest;
import org.testng.annotations.Test;
import static org.testng.Assert.*;

public class ContactsEJBTest
  extends AbstractContactsTest
{
  @Test
  public void testContactsEJB()
  {
    assertEquals( 22, s( ContactsService.class ).getContactDetails().size() );
  }
}
