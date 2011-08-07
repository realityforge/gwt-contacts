package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.user.client.ui.Widget;

import java.util.List;

public interface ContactsView
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

  Widget asWidget();
}
