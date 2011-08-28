package org.realityforge.guiceyloops;

import com.google.inject.MembersInjector;
import com.google.inject.Provider;
import com.google.inject.spi.TypeEncounter;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

public class JpaTypeListener
    extends AnnotationTypeListener
{
  public JpaTypeListener()
  {
    super( PersistenceContext.class, new Class[]{ EntityManager.class } );
  }

  protected <T> MembersInjector<T> createInjector( final TypeEncounter<T> typeEncounter,
                                                   final Annotation annotation,
                                                   final Field field )
  {
    final PersistenceContext context = (PersistenceContext) annotation;
    return new JpaFieldInjector<T>( typeEncounter, context, field );
  }

  private static final class JpaFieldInjector<T>
      extends FieldBasedInjector<T>
  {
    private final Provider<EntityManager> _provider;

    private JpaFieldInjector( final TypeEncounter<T> typeEncounter, final Annotation annotation, final Field field )
    {
      super( typeEncounter, annotation, field );
      _provider = getTypeEncounter().getProvider( EntityManager.class );
    }

    protected Object getValue()
    {
      return _provider.get();
    }
  }
}
