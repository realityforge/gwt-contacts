package com.google.gwt.sample.contacts.client.common;

import com.google.gwt.sample.contacts.shared.ContactDetails;
//import com.google.gwt.user.client.ui.CheckBox;
//import com.google.gwt.user.client.ui.Widget;
import java.util.ArrayList;

@SuppressWarnings("serial")
public class ContactsColumnDefinitionsImpl extends 
    ArrayList<ColumnDefinition<ContactDetails>> {
  
  private static ContactsColumnDefinitionsImpl instance = null;
  
  public static ContactsColumnDefinitionsImpl getInstance() {
    if (instance == null) {
      instance = new ContactsColumnDefinitionsImpl();
    }
    
    return instance;
  }
  
  protected ContactsColumnDefinitionsImpl() {
    this.add(new ColumnDefinition<ContactDetails>() {
      public void render(ContactDetails c, StringBuilder sb) {
        sb.append("<input type='checkbox'/>");
      }

      public boolean isSelectable() {
        return true;
      }
    });

    this.add(new ColumnDefinition<ContactDetails>() {
      public void render(ContactDetails c, StringBuilder sb) {        
        sb.append("<div id='" + c.getDisplayName() + "'>" + c.getDisplayName() + "</div>");
      }

      public boolean isClickable() {
        return true;
      }
    });
  }
}
