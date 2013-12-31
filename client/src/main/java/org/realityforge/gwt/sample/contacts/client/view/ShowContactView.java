package org.realityforge.gwt.sample.contacts.client.view;

import org.realityforge.gwt.sample.contacts.client.data_type.contacts.ContactDTO;
import com.google.gwt.user.client.ui.IsWidget;

public interface ShowContactView
    extends IsWidget
{
  public interface Presenter
  {
    void onEditButtonClicked( ContactDTO contact );

    void onCancelButtonClicked();
  }

  void setPresenter( Presenter presenter );

  void setContact( ContactDTO contact );
}
