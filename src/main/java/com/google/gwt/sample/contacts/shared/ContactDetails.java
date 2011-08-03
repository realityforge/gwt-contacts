package com.google.gwt.sample.contacts.shared;

import java.io.Serializable;

@SuppressWarnings( "serial" )
public class ContactDetails
  implements Serializable
{
  private String _id;
  private String _displayName;

  public ContactDetails()
  {
    new ContactDetails( "0", "" );
  }

  public ContactDetails( final String id, final String displayName )
  {
    _id = id;
    _displayName = displayName;
  }

  public String getId()
  {
    return _id;
  }

  public String getDisplayName()
  {
    return _displayName;
  }
}
