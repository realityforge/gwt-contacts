package org.realityforge.gwt.sample.contacts.test.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.realityforge.guiceyloops.server.PersistenceTestModule;
import org.realityforge.gwt.sample.contacts.server.entity.ContactsPersistenceUnit;

public class ContactsPersistenceTestModule
  extends PersistenceTestModule
{
  public ContactsPersistenceTestModule()
  {
    super( true );
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
}
