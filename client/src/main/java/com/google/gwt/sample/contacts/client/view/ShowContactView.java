package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.ContactVO;
import com.google.gwt.user.client.ui.IsWidget;

public interface ShowContactView
    extends IsWidget
{
  public interface Presenter
  {
    void onEditButtonClicked( ContactVO contact );

    void onCancelButtonClicked();
  }

  void setPresenter( Presenter presenter );

  void setContact( ContactVO contact );
}
