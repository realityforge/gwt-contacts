package org.realityforge.guiceyloops;

import com.google.inject.MembersInjector;
import com.google.inject.Provider;
import com.google.inject.spi.TypeEncounter;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import javax.ejb.EJB;

public class EjbTypeListener
    extends AnnotationTypeListener
{
  public EjbTypeListener()
  {
    super( EJB.class );
  }

  protected <T> MembersInjector<T> createInjector( final TypeEncounter<T> typeEncounter,
                                                   final Annotation annotation,
                                                   final Field field )
  {
    final EJB context = (EJB) annotation;
    return new EjbFieldInjector<T>( typeEncounter, context, field );
  }

  private static final class EjbFieldInjector<T>
      extends FieldBasedInjector<T>
  {
    private final Provider<?> _provider;

    private EjbFieldInjector( final TypeEncounter<T> typeEncounter, final Annotation annotation, final Field field )
    {
      super( typeEncounter, annotation, field );
      _provider = getTypeEncounter().getProvider( field.getType() );
    }

    protected Object getValue()
    {
      return _provider.get();
    }
  }
}
