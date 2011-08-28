package org.realityforge.guiceyloops;

import com.google.inject.MembersInjector;
import com.google.inject.TypeLiteral;
import com.google.inject.spi.TypeEncounter;
import com.google.inject.spi.TypeListener;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;

public abstract class AnnotationTypeListener
    implements TypeListener
{
  private final Class<? extends Annotation> _annotation;
  private final Class<?>[] _acceptedTypes;

  protected AnnotationTypeListener( final Class<? extends Annotation> annotation )
  {
    this( annotation, new Class[ 0 ] );
  }

  protected AnnotationTypeListener( final Class<? extends Annotation> annotation,
                                    final Class<?>[] acceptedTypes )
  {
    _annotation = annotation;
    _acceptedTypes = acceptedTypes;
  }

  public <T> void hear( final TypeLiteral<T> typeLiteral,
                        final TypeEncounter<T> typeEncounter )
  {
    for( final Field field : typeLiteral.getRawType().getDeclaredFields() )
    {
      if( field.isAnnotationPresent( _annotation ) )
      {
        boolean accepted = _acceptedTypes.length == 0;
        for( final Class<?> type : _acceptedTypes )
        {
          if( field.getType() == type )
          {
            accepted = true;
            break;
          }
        }
        if( accepted )
        {
          final Annotation annotation = field.getAnnotation( _annotation );
          final MembersInjector<T> injector = createInjector( typeEncounter, annotation, field );
          typeEncounter.register( injector );
        }
      }
    }
  }

  protected abstract <T> MembersInjector<T> createInjector( TypeEncounter<T> typeEncounter,
                                                            Annotation annotation,
                                                            Field field );
}
