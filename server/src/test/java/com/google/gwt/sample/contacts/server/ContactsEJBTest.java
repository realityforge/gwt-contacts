package com.google.gwt.sample.contacts.server;

import javax.ejb.EJB;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.container.test.api.TargetsContainer;
import org.jboss.arquillian.junit.Arquillian;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.spec.JavaArchive;
import org.junit.Test;
import org.junit.runner.RunWith;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

@RunWith( Arquillian.class )
public class ContactsEJBTest
{
  @EJB
  private LocalContacts helloEJB;

  @Deployment
  public static JavaArchive createTestArchive()
  {
    return ShrinkWrap.create( JavaArchive.class, "Ignored.jar" )
        .addClasses( LocalContacts.class, ContactsEJB.class, ContactBean.class );
  }

  @Test
  public void testHelloEJB()
  {
    assertNotNull( helloEJB );
    assertEquals( 0, helloEJB.getContactDetails().size() );
  }
}


