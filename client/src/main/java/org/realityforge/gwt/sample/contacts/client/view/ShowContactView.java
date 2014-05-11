package org.realityforge.gwt.sample.contacts.client.view;

import com.google.gwt.user.client.ui.IsWidget;
import org.realityforge.gwt.sample.contacts.client.data_type.ContactDTO;

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
