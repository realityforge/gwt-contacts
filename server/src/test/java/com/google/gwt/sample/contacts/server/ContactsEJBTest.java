package com.google.gwt.sample.contacts.server;

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
  private static final String GLOBAL_JNDI_PREFIX = "java:global/" + APP_NAME + "/java/";

  private static EJBContainer c_container;

  @BeforeClass
  public static void setupContainer()
  {
    final Map<String, Object> properties = new HashMap<String, Object>();
    properties.put( EJBContainer.APP_NAME, APP_NAME );
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
    final LocalContacts ejb = lookup( ContactsEJB.EJB_NAME, LocalContacts.class );
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
      //noinspection unchecked
      return (T) context.lookup( jndiName );
    }
    catch ( final NamingException ne )
    {
      final String message = "Unable to find bean expected to be at " + jndiName;
      Assert.fail( message );
      return null;
    }
  }
}


