package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.user.client.ui.HasValue;
import com.google.gwt.user.client.ui.IsWidget;
import com.google.gwt.user.client.ui.Widget;

public interface EditContactView
  extends IsWidget
{
  public interface Presenter
  {
    void onSaveButtonClicked();

    void onCancelButtonClicked();
  }

  void setPresenter( Presenter presenter );

  HasValue<String> getFirstName();

  HasValue<String> getLastName();

  HasValue<String> getEmailAddress();
}
