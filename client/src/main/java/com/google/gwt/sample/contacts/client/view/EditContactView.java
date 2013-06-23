package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.client.data_type.contacts.ContactDTO;
import com.google.gwt.user.client.ui.IsWidget;

public interface EditContactView
  extends IsWidget
{
  public interface Presenter
  {
    void onSaveButtonClicked( ContactDTO contact );

    void onCancelButtonClicked();
  }

  void setPresenter( Presenter presenter );

  void setContact( ContactDTO contact );
}
