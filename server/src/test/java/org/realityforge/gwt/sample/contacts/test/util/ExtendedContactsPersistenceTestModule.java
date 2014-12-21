package org.realityforge.gwt.sample.contacts.test.util;

import javax.annotation.Nonnull;
import javax.persistence.Table;
import org.postgresql.Driver;
import org.realityforge.gwt.sample.contacts.server.test.util.ContactsPersistenceTestModule;

public class ExtendedContactsPersistenceTestModule
  extends ContactsPersistenceTestModule
{
  public ExtendedContactsPersistenceTestModule()
  {
    super( true );
    System.setProperty( "test.db.driver", Driver.class.getName() );
  }

  @Nonnull
  protected final String toQualifiedTableName( final Table annotation )
  {
    final String tableName = annotation.name();
    //Correctly quote table for postgres
    return "\"" + annotation.schema() + "\".\"" + ( tableName.startsWith( "vw" ) ? tableName.replace( "vw", "tbl" ) : tableName ) + "\"";
  }
}
