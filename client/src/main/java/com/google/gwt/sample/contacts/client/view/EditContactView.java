package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.ContactVO;
import com.google.gwt.user.client.ui.IsWidget;

public interface EditContactView
  extends IsWidget
{
  public interface Presenter
  {
    void onSaveButtonClicked( ContactVO contact );

    void onCancelButtonClicked();
  }

  void setPresenter( Presenter presenter );

  void setContact( ContactVO contact );
}
