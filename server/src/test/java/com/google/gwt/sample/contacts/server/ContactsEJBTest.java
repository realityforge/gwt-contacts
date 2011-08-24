package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.server.model.Contact;
import com.google.gwt.sample.contacts.server.model.dao.ContactDAO;
import com.google.gwt.sample.contacts.server.services.Contacts;
import com.google.gwt.sample.contacts.server.services.ContactsEJB;
import com.google.inject.AbstractModule;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.matcher.Matchers;
import java.util.HashMap;
import java.util.Properties;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import org.eclipse.persistence.jpa.PersistenceProvider;
import org.junit.Assert;
import org.junit.Test;

public class ContactsEJBTest
{
  @Test
  public void testHelloEJB()
  {
    Injector injector = Guice.createInjector( new TestModule() );
    final Contacts _contacts = injector.getInstance( Contacts.class );
    Assert.assertEquals( 22, _contacts.getContactDetails().size() );
  }

  public static class TestModule extends AbstractModule
  {
    protected void configure()
    {
      bind( Contacts.class ).to( ContactsEJB.class );
      bind( ContactDAO.class );
      bind( EntityManager.class ).toInstance( createEntityManager() );
      bindListener( Matchers.any(), new JpaTypeListener() );
    }

    private EntityManager createEntityManager()
    {
      final Properties properties = new Properties();
      properties.put( "javax.persistence.transactionType", "RESOURCE_LOCAL" );
      properties.put( "javax.persistence.jdbc.driver", "org.hsqldb.jdbcDriver" );
      properties.put( "javax.persistence.jdbc.url", "jdbc:hsqldb:mem:contacts" );
      properties.put( "javax.persistence.jdbc.user", "sa" );
      properties.put( "javax.persistence.jdbc.password", "" );
      //properties.put( "javax.persistence.provider", HibernatePersistence.class.getName() );
      //properties.put( "hibernate.hbm2ddl.auto", "create" );
      //properties.put( "hibernate.archive.autodetection", "class, hbm" );
      //properties.put( "hibernate.dialect", org.hibernate.dialect.HSQLDialect.class.getName() );

      properties.put( "javax.persistence.provider", org.eclipse.persistence.jpa.PersistenceProvider.class.getName() );
      properties.put( "eclipselink.ddl-generation", "create-tables" );
      properties.put( "eclipselink.ddl-generation.output-mode", "database" );

      final EntityManagerFactory factory = Persistence.createEntityManagerFactory( "test-contacts", properties );
      final EntityManager entityManager = factory.createEntityManager();
      entityManager.getTransaction().begin();
      //entityManager.createNativeQuery( "CREATE SCHEMA \"Contacts\" AUTHORIZATION DBA " ).executeUpdate();
      entityManager.getTransaction().commit();
      return entityManager;
    }
  }
}


