package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import java.util.ArrayList;
import javax.ejb.Local;

@Local
public interface LocalContacts
{
  Contact addContact(Contact contact);

  Boolean deleteContact(String id);

  ArrayList<ContactDetails> deleteContacts(ArrayList<String> ids);

  ArrayList<ContactDetails> getContactDetails();

  Contact getContact(String id);

  Contact updateContact(Contact contact);
}
