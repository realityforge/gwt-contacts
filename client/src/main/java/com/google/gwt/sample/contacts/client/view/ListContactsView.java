package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.ContactDetailsVO;
import com.google.gwt.user.client.ui.IsWidget;
import java.util.List;

public interface ListContactsView
  extends IsWidget
{
  public interface Presenter
  {
    void onAddButtonClicked();

    void onDeleteButtonClicked();

    void onItemClicked( ContactDetailsVO clickedItem );

    void onItemSelected( ContactDetailsVO selectedItem );
  }

  void setPresenter( Presenter presenter );

  void setRowData( List<ContactDetailsVO> rowData );
}
