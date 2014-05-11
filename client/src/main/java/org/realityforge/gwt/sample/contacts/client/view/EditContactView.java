package org.realityforge.gwt.sample.contacts.client.view;

import com.google.gwt.user.client.ui.IsWidget;
import org.realityforge.gwt.sample.contacts.client.data_type.ContactDTO;

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
