package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.user.client.ui.IsWidget;
import java.util.List;

public interface ListContactsView
  extends IsWidget
{
  public interface Presenter
  {
    void onAddButtonClicked();

    void onDeleteButtonClicked();

    void onItemClicked( ContactDetails clickedItem );

    void onItemSelected( ContactDetails selectedItem );
  }

  void setPresenter( Presenter presenter );

  void setRowData( List<ContactDetails> rowData );
}
