package com.google.gwt.sample.contacts.shared;

import java.io.Serializable;

@SuppressWarnings( "serial" )
public class ContactDetailsVO
  implements Serializable
{
  private String _id;
  private String _type;
  private String _displayName;

  public ContactDetailsVO()
  {
    this( "0", "", "" );
  }

  public ContactDetailsVO( final String id,
                           final String type,
                           final String displayName )
  {
    _id = id;
    _type = type;
    _displayName = displayName;
  }

  public String getId()
  {
    return _id;
  }

  public String getType()
  {
    return _type;
  }

  public String getDisplayName()
  {
    return _displayName;
  }
}
