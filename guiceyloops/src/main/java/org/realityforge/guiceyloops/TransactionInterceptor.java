package org.realityforge.guiceyloops;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

public class TransactionInterceptor
  implements MethodInterceptor
{
  @PersistenceContext
  private EntityManager _em;

  @PersistenceContext
  private int _depth;

  @Override
  public Object invoke( final MethodInvocation invocation )
    throws Throwable
  {
    try
    {
      if ( 0 == _depth )
      {
        _em.getTransaction().begin();
      }
      _depth++;

      final Object result = invocation.proceed();
      _depth--;

      if ( 0 == _depth )
      {
        _em.getTransaction().commit();
      }
      return result;
    }
    catch ( final Throwable t )
    {
      _depth--;
      if ( 0 == _depth )
      {
        _em.getTransaction().rollback();
      }

      throw t;
    }
  }
}
