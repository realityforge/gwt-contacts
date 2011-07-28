package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.client.common.ColumnDefinition;

import com.google.gwt.user.client.ui.Widget;

import java.util.List;

public interface ContactsView<T> {

  public interface Presenter<T> {
    void onAddButtonClicked();
    void onDeleteButtonClicked();
    void onItemClicked(T clickedItem);
    void onItemSelected(T selectedItem);
  }
  
  void setPresenter(Presenter<T> presenter);
  void setColumnDefinitions(List<ColumnDefinition<T>> columnDefinitions);
  void setRowData(List<T> rowData);
  Widget asWidget();
}
