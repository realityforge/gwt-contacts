package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.server.model.dao.ContactDAO;
import com.google.gwt.sample.contacts.server.services.Contacts;
import com.google.gwt.sample.contacts.server.services.ContactsEJB;
import com.google.inject.AbstractModule;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.matcher.Matchers;
import java.io.File;
import java.io.FileWriter;
import java.io.Writer;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Properties;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import org.junit.Assert;
import org.junit.Test;
import static com.google.inject.matcher.Matchers.annotatedWith;
import static com.google.inject.matcher.Matchers.any;

public class ContactsEJBTest
{
  @Test
  public void testHelloEJB()
  {
    Injector injector = Guice.createInjector( new TestModule() );
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
      bind( EntityManager.class ).toInstance( createEntityManager() );
      bindListener( Matchers.any(), new JpaTypeListener() );
      final TransactionInterceptor interceptor = new TransactionInterceptor();
      requestInjection( interceptor );
      bindInterceptor( annotatedWith( Stateless.class ),
                       any(),
                       interceptor );
    }

    private EntityManager createEntityManager()
    {
      final File file;
      final String url;
      try
      {
        final File dbFile = File.createTempFile( "database", "db" );
        file = File.createTempFile( "schema_create", "sql" );
        final Writer stream = new FileWriter( file );
        stream.write( "CREATE SCHEMA Contacts;\n" );
        stream.close();
        Class.forName( "org.h2.Driver" );
        url = "jdbc:h2:file:" + dbFile.getAbsolutePath().replace( '\\', '/' );
        final Statement statement = DriverManager.getConnection( url, "sa", "" ).createStatement();
        statement.execute( "CREATE SCHEMA Contacts;\n" );
      }
      catch ( final Exception e )
      {
        throw new IllegalStateException( e );
      }

      final Properties properties = new Properties();
      properties.put( "javax.persistence.transactionType", "RESOURCE_LOCAL" );
      properties.put( "javax.persistence.jdbc.driver", "org.h2.Driver" );
      properties.put( "javax.persistence.jdbc.url", url );
      properties.put( "javax.persistence.jdbc.user", "sa" );
      properties.put( "javax.persistence.jdbc.password", "" );

      properties.put( "javax.persistence.provider", org.eclipse.persistence.jpa.PersistenceProvider.class.getName() );
      properties.put( "eclipselink.ddl-generation", "create-tables" );
      properties.put( "eclipselink.ddl-generation.output-mode", "database" );

      final EntityManagerFactory factory = Persistence.createEntityManagerFactory( "test-contacts", properties );
      final EntityManager entityManager = factory.createEntityManager();
      return entityManager;
    }
  }
}


