package com.google.gwt.sample.contacts.server;

import javax.persistence.GenerationType;

@SuppressWarnings( "serial" )
@javax.persistence.NamedQueries( value = {
  @javax.persistence.NamedQuery( name = ContactBean.findAll, query = "SELECT O FROM AddressBook.Contact O " ),
  @javax.persistence.NamedQuery( name = ContactBean.findByID,
                                 query = "SELECT O FROM AddressBook.Contact O WHERE O.ID = :ID" )
} )
@javax.persistence.Access( javax.persistence.AccessType.FIELD )
@javax.persistence.Entity( name = "AddressBook.Contact" )
@javax.persistence.Table( name = "tblContact",
                          schema = "AddressBook",
                          uniqueConstraints = { } )
public class ContactBean
{
  public static final String findAll = "com.google.gwt.sample.contacts.shared.ContactBean.findAll";
  public static final String findByID = "com.google.gwt.sample.contacts.shared.ContactBean.findByID";

  @javax.persistence.Id
  @javax.persistence.GeneratedValue( strategy = GenerationType.AUTO )
  @javax.persistence.Column( name = "ID", nullable = false, updatable = false, unique = false, insertable = false )
  private Integer ID;

  @javax.persistence.Column( name = "FirstName", nullable = true, updatable = true, unique = false, insertable = true )
  private String FirstName;

  @javax.persistence.Column( name = "LastName", nullable = true, updatable = true, unique = false, insertable = true )
  private String LastName;

  @javax.persistence.Column( name = "EmailAddress", nullable = true, updatable = true, unique = false,
                             insertable = true )
  private String EmailAddress;

  public Integer getID()
  {
    return ID;
  }

  public String getFirstName()
  {
    return FirstName;
  }

  public void setFirstName( final String firstName )
  {
    this.FirstName = firstName;
  }

  public String getLastName()
  {
    return LastName;
  }

  public void setLastName( final String lastName )
  {
    this.LastName = lastName;
  }

  public String getEmailAddress()
  {
    return EmailAddress;
  }

  public void setEmailAddress( final String emailAddress )
  {
    this.EmailAddress = emailAddress;
  }

  public String getFullName()
  {
    return FirstName + " " + LastName;
  }
}
