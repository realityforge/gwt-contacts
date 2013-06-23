package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.client.data_type.contacts.ContactDetailsDTO;
import com.google.gwt.user.client.ui.IsWidget;
import java.util.List;

public interface ListContactsView
  extends IsWidget
{
  public interface Presenter
  {
    void onAddButtonClicked();

    void onDeleteButtonClicked();

    void onItemClicked( ContactDetailsDTO clickedItem );

    void onItemSelected( ContactDetailsDTO selectedItem );
  }

  void setPresenter( Presenter presenter );

  void setRowData( List<ContactDetailsDTO> rowData );
}
