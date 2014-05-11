package org.realityforge.gwt.sample.contacts.test.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.annotation.Nonnull;
import javax.persistence.Table;
import org.postgresql.Driver;
import org.realityforge.guiceyloops.server.PersistenceTestModule;
import org.realityforge.gwt.sample.contacts.server.entity.ContactsPersistenceUnit;

public class ContactsPersistenceTestModule
  extends PersistenceTestModule
{
  public ContactsPersistenceTestModule()
  {
    super( true );
    System.setProperty( "test.db.driver", Driver.class.getName() );
  }

  @Override
  protected String getPersistenceUnitName()
  {
    return ContactsPersistenceUnit.NAME;
  }

  protected void configure()
  {
    super.configure();
    final List<String> tables = new ArrayList<String>();
    for ( final Class model : ContactsPersistenceUnit.getContactsModels() )
    {
      requestInjectionForEntityListener( model );
      collectTableName( tables, model );
    }
    Collections.reverse( tables );

    requestCleaningOfTables( tables.toArray( new String[ tables.size() ] ) );
  }

  @Nonnull
  protected final String toQualifiedTableName( final Table annotation )
  {
    final String tableName = annotation.name();
    //Correctly quote table for postgres
    return "\"" + annotation.schema() + "\".\"" + ( tableName.startsWith( "vw" ) ? tableName.replace( "vw", "tbl" ) : tableName ) + "\"";
  }
}
