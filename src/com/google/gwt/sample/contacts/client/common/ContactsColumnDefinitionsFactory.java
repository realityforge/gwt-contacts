package com.google.gwt.sample.contacts.client.common;

import com.google.gwt.sample.contacts.shared.ContactDetails;
import java.util.ArrayList;
import java.util.List;

public class ContactsColumnDefinitionsFactory<T> {
  public static List<ColumnDefinition<ContactDetails>> 
      getContactsColumnDefinitions() {
    return ContactsColumnDefinitionsImpl.getInstance();
  }

  public static List<ColumnDefinition<ContactDetails>>
      getTestContactsColumnDefinitions() {
    return new ArrayList<ColumnDefinition<ContactDetails>>();
  }
}
