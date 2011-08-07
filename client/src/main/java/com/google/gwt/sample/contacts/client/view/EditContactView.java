package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.event.dom.client.HasClickHandlers;
import com.google.gwt.user.client.ui.HasValue;
import com.google.gwt.user.client.ui.Widget;

public interface EditContactView
{
  public interface Presenter
    extends com.google.gwt.sample.contacts.client.Presenter
  {
  }

  HasClickHandlers getSaveButton();

  HasClickHandlers getCancelButton();

  HasValue<String> getFirstName();

  HasValue<String> getLastName();

  HasValue<String> getEmailAddress();

  Widget asWidget();
}
