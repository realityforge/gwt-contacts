package com.google.gwt.sample.contacts.shared;

import java.io.Serializable;

@SuppressWarnings( "serial" )
public class Contact
  implements Serializable
{
  private String id;
  private String firstName;
  private String lastName;
  private String emailAddress;

  public Contact()
  {
  }

  public Contact( final String id, final String firstName, final String lastName, final String emailAddress )
  {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.emailAddress = emailAddress;
  }

  public String getId()
  {
    return id;
  }

  public String getFirstName()
  {
    return firstName;
  }

  public void setFirstName( String firstName )
  {
    this.firstName = firstName;
  }

  public String getLastName()
  {
    return lastName;
  }

  public void setLastName( String lastName )
  {
    this.lastName = lastName;
  }

  public String getEmailAddress()
  {
    return emailAddress;
  }

  public void setEmailAddress( String emailAddress )
  {
    this.emailAddress = emailAddress;
  }
}
