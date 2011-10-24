package com.google.gwt.sample.contacts.shared;

import java.io.Serializable;

@SuppressWarnings( "serial" )
public class ContactVO
    implements Serializable
{
  private String _id;
  private String _type;
  private String _firstName;
  private String _lastName;
  private String _emailAddress;

  public ContactVO()
  {
  }

  public ContactVO( final String id,
                    final String type,
                    final String firstName,
                    final String lastName,
                    final String emailAddress )
  {
    _type = type;
    _id = id;
    _firstName = firstName;
    _lastName = lastName;
    _emailAddress = emailAddress;
  }

  public String getId()
  {
    return _id;
  }

  public String getType()
  {
    return _type;
  }

  public String getFirstName()
  {
    return _firstName;
  }

  public void setFirstName( final String firstName )
  {
    _firstName = firstName;
  }

  public String getLastName()
  {
    return _lastName;
  }

  public void setLastName( final String lastName )
  {
    _lastName = lastName;
  }

  public String getEmailAddress()
  {
    return _emailAddress;
  }

  public void setEmailAddress( final String emailAddress )
  {
    _emailAddress = emailAddress;
  }

  public String toString()
  {
    return "Contact[" + getId() +
           ", Type=" + getType() +
           ", FirstName=" + getFirstName() +
           ", LastName=" + getLastName() +
           ", Email=" + getEmailAddress() + "]";
  }
}
