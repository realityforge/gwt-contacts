package com.google.gwt.sample.contacts.client;

import com.smartgwt.client.data.DataSource;
import com.smartgwt.client.data.fields.DataSourceFloatField;
import com.smartgwt.client.data.fields.DataSourceIntegerField;
import com.smartgwt.client.data.fields.DataSourceTextField;

public class ContactsXmlDS
  extends DataSource
{
  private static ContactsXmlDS instance = null;

  public static ContactsXmlDS getInstance()
  {
    if ( instance == null )
    {
      instance = new ContactsXmlDS( "contactsDS" );
    }
    return instance;
  }

  public ContactsXmlDS( final String id )
  {
    setID( id );
    setTitleField( "Name" );
    setRecordXPath( "/List/employee" );
    final DataSourceTextField nameField = new DataSourceTextField( "Name", "Name", 128 );
    final DataSourceIntegerField employeeIdField = new DataSourceIntegerField( "EmployeeId", "Employee ID" );
    employeeIdField.setPrimaryKey( true );
    employeeIdField.setRequired( true );

    final DataSourceIntegerField reportsToField = new DataSourceIntegerField( "ReportsTo", "Manager" );
    reportsToField.setRequired( true );
    reportsToField.setForeignKey( id + ".EmployeeId" );
    reportsToField.setRootValue( "1" );

    final DataSourceTextField jobField = new DataSourceTextField( "Job", "Title", 128 );
    final DataSourceTextField emailField = new DataSourceTextField( "Email", "Email", 128 );
    final DataSourceTextField statusField = new DataSourceTextField( "EmployeeStatus", "Status", 40 );
    final DataSourceFloatField salaryField = new DataSourceFloatField( "Salary", "Salary" );
    final DataSourceTextField orgField = new DataSourceTextField( "OrgUnit", "Org Unit", 128 );
    final DataSourceTextField genderField = new DataSourceTextField( "Gender", "Gender", 7 );
    genderField.setValueMap( "male", "female" );
    final DataSourceTextField maritalStatusField = new DataSourceTextField( "MaritalStatus", "Marital Status", 10 );

    setFields( nameField, employeeIdField, reportsToField, jobField, emailField,
               statusField, salaryField, orgField, genderField, maritalStatusField );

    setDataURL( "ds/contacts_data.xml" );
    setClientOnly( true );
  }
}