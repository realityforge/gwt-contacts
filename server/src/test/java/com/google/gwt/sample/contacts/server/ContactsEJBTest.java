package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.server.services.Contacts;
import java.util.HashMap;
import java.util.Map;
import javax.ejb.embeddable.EJBContainer;
import javax.naming.Context;
import javax.naming.NamingException;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

public class ContactsEJBTest
{
  private static final String APP_NAME = "sample";
  private static final String MODULE_NAME = "contacts";
  private static final String GLOBAL_JNDI_PREFIX = "java:global/" + APP_NAME + "/" + MODULE_NAME + "/";

  private static final java.lang.String KEEP_TEMPORARY_FILES = "org.glassfish.ejb.embedded.keep-temporary-files";
  private static final java.lang.String SKIP_CLIENT_MODULES = "org.glassfish.ejb.embedded.skip-client-modules";
  private static final java.lang.String GF_INSTALLATION_ROOT = "org.glassfish.ejb.embedded.glassfish.installation.root";
  private static final java.lang.String GF_INSTANCE_ROOT = "org.glassfish.ejb.embedded.glassfish.instance.root";
  private static final java.lang.String GF_DOMAIN_FILE = "org.glassfish.ejb.embedded.glassfish.configuration.file";
  private static final java.lang.String GF_INSTANCE_REUSE = "org.glassfish.ejb.embedded.glassfish.instance.reuse";
  private static final java.lang.String GF_WEB_HTTP_PORT = "org.glassfish.ejb.embedded.glassfish.web.http.port";
  private static final java.lang.String WEAVING = "org.glassfish.persistence.embedded.weaving.enabled";

  private static EJBContainer c_container;

  @BeforeClass
  public static void setupContainer()
  {
    final Map<String, Object> properties = new HashMap<String, Object>();
    properties.put( EJBContainer.APP_NAME, APP_NAME );
    properties.put( EJBContainer.MODULES, MODULE_NAME );

    //noinspection ConstantIfStatement
    if ( false )
    {
      properties.put( GF_INSTALLATION_ROOT, "XXX" );
      properties.put( GF_INSTANCE_ROOT, "XXX" );

      /** The configuration file. */
      properties.put( GF_DOMAIN_FILE, "<domain-dir>/config/domain.xml" );
    }

    /*
     * If true, keeps temporary files (exploded EAR file and configuration file) created by the embedded EJB
     * container when Embedded GlassFish Server is stopped.
     */
    properties.put( KEEP_TEMPORARY_FILES, true );

    /**
     * If true, no changes are made to the existing configuration file, and a temporary server instance is not
     * created for the embedded run. Instead, execution happens against the existing server instance. Do not use
     * this option if the reused server instance could be in use by the running GlassFish Server.
     */
    properties.put( GF_INSTANCE_REUSE, "false" );

    /**
     * If true, omits modules from the classpath if they are not specified using EJBContainer.MODULES and have a
     * manifest file with a Main-Class attribute.
     */
    properties.put( SKIP_CLIENT_MODULES, true );

    properties.put( WEAVING, "true" );

    properties.put( GF_WEB_HTTP_PORT, null );

    //Logger.getLogger("").getHandlers()[0].setLevel(Level.FINEST);
    //Logger.getLogger("javax.enterprise.system.tools.deployment").setLevel(Level.FINEST);
    //Logger.getLogger( "javax.enterprise.system" ).setLevel( Level.FINEST);

    c_container = EJBContainer.createEJBContainer( properties );
  }

  @AfterClass
  public static void shutdownContainer()
  {
    if ( null != c_container )
    {
      c_container.close();
      c_container = null;
    }
  }

  @Test
  public void testHelloEJB()
  {
    //TODO: This does not work from Buildr as the compiled artifacts are split across multiple directories and
    // EJBContainer wants them to be in one directory
    final Contacts ejb = lookup( Contacts.EJB_NAME, Contacts.class );
    assertEquals( 22, ejb.getContactDetails().size() );
  }

  private <T> T lookup( final String name, final Class<T> type )
  {
    final String jndiName = GLOBAL_JNDI_PREFIX + name + ( type.isInterface() ? "!" + type.getName() : "" );
    return lookupInContext( jndiName, type );
  }

  private <T> T lookupInContext( final String jndiName, final Class<T> type )
  {
    try
    {
      final Context context = c_container.getContext();
      return type.cast( context.lookup( jndiName ) );
    }
    catch ( final NamingException ne )
    {
      final String message = "Unable to find bean expected to be at " + jndiName;
      Assert.fail( message );
      return null;
    }
  }
}


