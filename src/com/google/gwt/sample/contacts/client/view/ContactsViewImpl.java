package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.client.common.ColumnDefinition;
import com.google.gwt.sample.contacts.client.common.SelectionModel;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.uibinder.client.UiTemplate;
import com.google.gwt.dom.client.Document;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.EventTarget;
import com.google.gwt.dom.client.Node;
import com.google.gwt.dom.client.NodeList;
import com.google.gwt.dom.client.TableCellElement;
import com.google.gwt.dom.client.TableElement;
import com.google.gwt.dom.client.TableRowElement;
import com.google.gwt.dom.client.TableSectionElement;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Event;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HTMLTable;
import com.google.gwt.user.client.ui.Widget;

import java.util.ArrayList;
import java.util.List;

public class ContactsViewImpl<T> extends Composite implements ContactsView<T> {

  @UiTemplate("ContactsView.ui.xml")
  interface ContactsViewUiBinder extends UiBinder<Widget, ContactsViewImpl> {}
  private static ContactsViewUiBinder uiBinder = 
    GWT.create(ContactsViewUiBinder.class);

  @UiField HTML contactsTable;
  @UiField Button addButton;
  @UiField Button deleteButton;

  private Presenter<T> presenter;
  private List<ColumnDefinition<T>> columnDefinitions;
  private List<T> rowData;
  
  public ContactsViewImpl() {
    initWidget(uiBinder.createAndBindUi(this));
  }
  
  public void setPresenter(Presenter<T> presenter) {
    this.presenter = presenter;
  }
  
  public void setColumnDefinitions(
      List<ColumnDefinition<T>> columnDefinitions) {
    this.columnDefinitions = columnDefinitions;
  }
  
  public void setRowData(List<T> rowData) {
    this.rowData = rowData;

    TableElement table = Document.get().createTableElement();
    TableSectionElement tbody;
    table.appendChild(tbody = Document.get().createTBodyElement());

    for (int i = 0; i < rowData.size(); ++i) {
      TableRowElement row = tbody.insertRow(-1);
      T t = rowData.get(i);

      for (int j = 0; j < columnDefinitions.size(); ++j) {
        TableCellElement cell = row.insertCell(-1);
        StringBuilder sb = new StringBuilder();
        columnDefinitions.get(j).render(t, sb);
        cell.setInnerHTML(sb.toString());

        // TODO: Really total hack! There's gotta be a better way...
        Element child = cell.getFirstChildElement();
        if (child != null) {
          Event.sinkEvents(child, Event.ONFOCUS | Event.ONBLUR);
        }
      }
    }
    
    contactsTable.setHTML(table.getInnerHTML());
  }
  
  @UiHandler("addButton")
  void onAddButtonClicked(ClickEvent event) {
    if (presenter != null) {
      presenter.onAddButtonClicked();
    }
  }

  @UiHandler("deleteButton")
  void onDeleteButtonClicked(ClickEvent event) {
    if (presenter != null) {
      presenter.onDeleteButtonClicked();
    }
  }
  
  private TableCellElement findNearestParentCell(Node node) {
    while ((node != null)) {
      if (Element.is(node)) {
        Element elem = Element.as(node);

        String tagName = elem.getTagName();
        if ("td".equalsIgnoreCase(tagName) || "th".equalsIgnoreCase(tagName)) {
          return elem.cast();
        }
      }
      node = node.getParentNode();
    }
    return null;
  }


  @UiHandler("contactsTable")
  void onTableClicked(ClickEvent event) {
    if (presenter != null) {
      EventTarget target = event.getNativeEvent().getEventTarget();
      Node node = Node.as(target);
      TableCellElement cell = findNearestParentCell(node);
      if (cell == null) {
        return;
      }

      TableRowElement tr = TableRowElement.as(cell.getParentElement());
      int row = tr.getSectionRowIndex();
      
      if (cell != null) {
        if (shouldFireClickEvent(cell)) {
          presenter.onItemClicked(rowData.get(row));
        }
        if (shouldFireSelectEvent(cell)) {
          presenter.onItemSelected(rowData.get(row));
        }
      }
    }
  }

  private boolean shouldFireClickEvent(TableCellElement cell) {
    boolean shouldFireClickEvent = false;
    
    if (cell != null) {
      ColumnDefinition<T> columnDefinition = 
        columnDefinitions.get(cell.getCellIndex());
      
      if (columnDefinition != null) {
        shouldFireClickEvent = columnDefinition.isClickable();
      }
    }

    return shouldFireClickEvent;
  }
  
  private boolean shouldFireSelectEvent(TableCellElement cell) {
    boolean shouldFireSelectEvent = false;
    
    if (cell != null) {
      ColumnDefinition<T> columnDefinition = 
        columnDefinitions.get(cell.getCellIndex());
      
      if (columnDefinition != null) {
        shouldFireSelectEvent = columnDefinition.isSelectable();
      }
    }

    return shouldFireSelectEvent;
  }
  
  public Widget asWidget() {
    return this;
  }
}
