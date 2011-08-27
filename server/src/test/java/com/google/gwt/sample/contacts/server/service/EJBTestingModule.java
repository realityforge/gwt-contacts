package com.google.gwt.sample.contacts.server.service;

import com.google.inject.AbstractModule;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Properties;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public class EJBTestingModule
  extends AbstractModule
{
  private static final String DRIVER_KEY = "javax.persistence.jdbc.driver";
  private static final String USER_KEY = "javax.persistence.jdbc.user";
  private static final String PASSWORD_KEY = "javax.persistence.jdbc.password";
  private static final String URL_KEY = "javax.persistence.jdbc.url";
  private static final String PROVIDER_KEY = "javax.persistence.provider";

  private final List<String> _schemas;

  public EJBTestingModule( final String... schemas )
  {
    _schemas = new ArrayList<String>( schemas.length );
    Collections.addAll( _schemas, schemas );
  }

  protected void configure()
  {
    bind( EntityManager.class ).toInstance( createEntityManager() );
  }

  private EntityManager createEntityManager()
  {
    final String url = getJdbcURL();


    final Properties properties = setupProperties( url );

    try
    {
      final String driver = (String) properties.get( DRIVER_KEY );
      final String user = (String) properties.get( USER_KEY );
      final String password = (String) properties.get( PASSWORD_KEY );
      Class.forName( driver );
      final Connection connection = DriverManager.getConnection( url, user, password );
      final Statement statement = connection.createStatement();

      for ( final String schema : _schemas )
      {
        statement.execute( "CREATE SCHEMA " + schema + ";\n" );
      }
      connection.close();
    }
    catch ( final Exception e )
    {
      throw new IllegalStateException( e );
    }

    final EntityManagerFactory factory = Persistence.createEntityManagerFactory( "test-contacts", properties );
    return factory.createEntityManager();
  }

  private Properties setupProperties( final String url )
  {
    final Properties properties = new Properties();
    properties.put( DRIVER_KEY, "org.h2.Driver" );
    properties.put( URL_KEY, url );
    properties.put( USER_KEY, "sa" );
    properties.put( PASSWORD_KEY, "" );
    properties.put( PROVIDER_KEY, org.eclipse.persistence.jpa.PersistenceProvider.class.getName() );

    properties.put( "eclipselink.ddl-generation", "create-tables" );
    properties.put( "eclipselink.ddl-generation.output-mode", "database" );

    return properties;
  }

  private String getJdbcURL()
  {
    try
    {
      final File dbFile = File.createTempFile( "database", "db" );
      dbFile.deleteOnExit();
      return "jdbc:h2:file:" + dbFile.getAbsolutePath().replace( '\\', '/' );
    }
    catch ( final IOException ioe )
    {
      throw new IllegalStateException( ioe );
    }
  }
}
