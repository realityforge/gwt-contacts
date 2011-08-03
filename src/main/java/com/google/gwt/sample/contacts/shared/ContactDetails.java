package com.google.gwt.sample.contacts.shared;

import java.io.Serializable;

@SuppressWarnings( "serial" )
public class ContactDetails
  implements Serializable
{
  private String id;
  private String displayName;

  public ContactDetails()
  {
    new ContactDetails( "0", "" );
  }

  public ContactDetails( final String id, final String displayName )
  {
    this.id = id;
    this.displayName = displayName;
  }

  public String getId()
  {
    return id;
  }

  public void setId( final String id )
  {
    this.id = id;
  }

  public String getDisplayName()
  {
    return displayName;
  }

  public void setDisplayName( final String displayName )
  {
    this.displayName = displayName;
  }
}
