package org.realityforge.gwt.sample.contacts.test.util;

import com.google.inject.Module;
import java.util.ArrayList;
import java.util.Collections;
import org.realityforge.guiceyloops.server.AbstractServerTest;
import org.realityforge.guiceyloops.server.ServerTestModule;
import org.realityforge.gwt.sample.contacts.server.ContactsRepositoryModule;

public class AbstractContactsTest
  extends AbstractServerTest
{
  @Override
  protected Module getEntityModule()
  {
    return new ContactsPersistenceTestModule();
  }

  @Override
  protected Module[] getModules()
  {
    final ArrayList<Module> modules = new ArrayList<Module>();
    Collections.addAll( modules, super.getModules() );
    modules.add( new ContactsRepositoryModule() );
    return modules.toArray( new Module[ modules.size() ] );
  }

  @Override
  protected ServerTestModule getDefaultTestModule()
  {
    return new ContactsTestModule( this );
  }
}
