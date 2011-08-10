package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.user.client.ui.IsWidget;

public interface EditContactView
  extends IsWidget
{
  public interface Presenter
  {
    void onSaveButtonClicked( Contact contact );

    void onCancelButtonClicked();
  }

  void setPresenter( Presenter presenter );

  void setContact( Contact contact );
}
