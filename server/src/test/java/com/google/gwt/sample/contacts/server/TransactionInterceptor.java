package com.google.gwt.sample.contacts.server;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

public class TransactionInterceptor
  implements MethodInterceptor
{
  @PersistenceContext
  private EntityManager em;

  @PersistenceContext
  private int depth;

  @Override
  public Object invoke( MethodInvocation invocation )
    throws Throwable
  {
    try
    {
      if ( 0 == depth )
      {
        em.getTransaction().begin();
      }
      depth++;

      final Object result = invocation.proceed();
      depth--;

      if ( 0 == depth )
      {
        em.getTransaction().commit();
      }
      return result;
    }
    catch ( final Throwable t )
    {
      depth--;
      if ( 0 == depth )
      {
        em.getTransaction().rollback();
      }

      throw t;
    }
  }
}
