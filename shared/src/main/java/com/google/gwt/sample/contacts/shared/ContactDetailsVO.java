package com.google.gwt.sample.contacts.shared;

import java.io.Serializable;

@SuppressWarnings( "serial" )
public class ContactDetailsVO
  implements Serializable
{
  private String _id;
  private String _displayName;

  public ContactDetailsVO()
  {
    this( "0", "" );
  }

  public ContactDetailsVO( final String id, final String displayName )
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
