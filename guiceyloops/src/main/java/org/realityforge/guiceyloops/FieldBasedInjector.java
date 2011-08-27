package org.realityforge.guiceyloops;

import com.google.inject.MembersInjector;
import com.google.inject.spi.TypeEncounter;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;

public abstract class FieldBasedInjector<T> implements MembersInjector<T>
{
  private final TypeEncounter<T> _typeEncounter;
  private final Annotation _annotation;
  private final Field _field;

  FieldBasedInjector( final TypeEncounter<T> typeEncounter, final Annotation annotation, final Field field )
  {
    _typeEncounter = typeEncounter;
    _annotation = annotation;
    _field = field;
    _field.setAccessible( true );
  }

  public void injectMembers( final T t )
  {
    try
    {
      _field.set( t, getValue() );
    }
    catch( IllegalAccessException e )
    {
      throw new RuntimeException( e );
    }
  }

  protected final TypeEncounter<T> getTypeEncounter()
  {
    return _typeEncounter;
  }

  protected final Annotation getAnnotation()
  {
    return _annotation;
  }

  protected final Field getField()
  {
    return _field;
  }

  protected abstract Object getValue();
}
