package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Document;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.TableCellElement;
import com.google.gwt.dom.client.TableElement;
import com.google.gwt.dom.client.TableRowElement;
import com.google.gwt.dom.client.TableSectionElement;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.client.common.ColumnDefinition;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Event;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTMLTable;
import com.google.gwt.user.client.ui.Widget;
import java.util.List;

public class ContactsViewImpl<T>
  extends Composite
  implements ContactsView<T>
{
  interface ContactsViewUiBinder
    extends UiBinder<Widget, ContactsViewImpl>
  {
  }

  private static final ContactsViewUiBinder uiBinder = GWT.create( ContactsViewUiBinder.class );

  @UiField
  FlexTable contactsTable;
  @UiField
  Button addButton;
  @UiField
  Button deleteButton;

  private Presenter<T> presenter;
  private List<ColumnDefinition<T>> columnDefinitions;
  private List<T> rowData;

  public ContactsViewImpl()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  public void setPresenter( final Presenter<T> presenter )
  {
    this.presenter = presenter;
  }

  public void setColumnDefinitions( final List<ColumnDefinition<T>> columnDefinitions )
  {
    this.columnDefinitions = columnDefinitions;
  }

  public void setRowData( final List<T> rowData )
  {
    contactsTable.removeAllRows();
      this.rowData = rowData;

    for ( int i = 0; i < rowData.size(); ++i )
    {
      final T t = rowData.get( i );
      for ( int j = 0; j < columnDefinitions.size(); ++j )
      {
        contactsTable.setWidget( i, j, columnDefinitions.get( j ).render( t ) );
      }
    }
  }

  @UiHandler( "addButton" )
  void onAddButtonClicked( final ClickEvent event )
  {
    if ( presenter != null )
    {
      presenter.onAddButtonClicked();
    }
  }

  @UiHandler( "deleteButton" )
  void onDeleteButtonClicked( final ClickEvent event )
  {
    if ( presenter != null )
    {
      presenter.onDeleteButtonClicked();
    }
  }

  @UiHandler( "contactsTable" )
  void onTableClicked( final ClickEvent event )
  {
    if ( presenter != null )
    {
      final HTMLTable.Cell cell = contactsTable.getCellForEvent( event );
      if ( null != cell )
      {
        if ( shouldFireClickEvent( cell ) )
        {
          presenter.onItemClicked( rowData.get( cell.getRowIndex() ) );
        }

        if ( shouldFireSelectEvent( cell ) )
        {
          presenter.onItemSelected( rowData.get( cell.getRowIndex() ) );

        }
      }
    }
  }

  private boolean shouldFireClickEvent( final HTMLTable.Cell cell )
  {
    final ColumnDefinition<T> definition = columnDefinitions.get( cell.getCellIndex() );
    if ( definition != null )
    {
      return definition.isClickable();
    }
    return false;
  }

  private boolean shouldFireSelectEvent( final HTMLTable.Cell cell )
  {
    final ColumnDefinition<T> definition = columnDefinitions.get( cell.getCellIndex() );
    if ( null != definition )
    {
      return definition.isSelectable();
    }
    return false;
  }

  public Widget asWidget()
  {
    return this;
  }
}
