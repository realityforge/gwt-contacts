package com.google.gwt.sample.contacts.server.service;

import com.google.gwt.sample.contacts.server.entity.dao.ContactDAO;
import com.google.inject.AbstractModule;
import com.google.inject.Guice;
import com.google.inject.Injector;
import org.junit.Assert;
import org.junit.Test;
import org.realityforge.guiceyloops.JEETestingModule;

public class ContactsEJBTest
{
  @Test
  public void testContactsEJB()
  {
    Injector injector = Guice.createInjector( new TestModule(), new EJBTestingModule( "Contacts" ), new JEETestingModule() );
    final Contacts _contacts = injector.getInstance( Contacts.class );
    Assert.assertEquals( 22, _contacts.getContactDetails().size() );
  }

  public static class TestModule
    extends AbstractModule
  {
    protected void configure()
    {
      bind( Contacts.class ).to( ContactsEJB.class );
      bind( ContactDAO.class );
    }
  }
}


