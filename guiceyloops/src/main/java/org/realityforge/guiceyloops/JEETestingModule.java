package org.realityforge.guiceyloops;

import com.google.inject.AbstractModule;
import com.google.inject.matcher.Matchers;
import javax.ejb.Stateless;
import static com.google.inject.matcher.Matchers.annotatedWith;
import static com.google.inject.matcher.Matchers.any;

public class JEETestingModule
    extends AbstractModule
{
  protected void configure()
  {
    bindListener( Matchers.any(), new JpaTypeListener() );
    bindListener( Matchers.any(), new EjbTypeListener() );
    final TransactionInterceptor interceptor = new TransactionInterceptor();
    requestInjection( interceptor );
    bindInterceptor( annotatedWith( Stateless.class ),
                     any(),
                     interceptor );
  }
}
