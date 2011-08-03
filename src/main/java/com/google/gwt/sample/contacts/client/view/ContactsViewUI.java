package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.client.common.ColumnDefinition;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTMLTable;
import com.google.gwt.user.client.ui.Widget;
import java.util.List;

public class ContactsViewUI<T>
  extends Composite
  implements ContactsView<T>
{
  interface ContactsViewUiBinder
    extends UiBinder<Widget, ContactsViewUI>
  {
  }

  private static final ContactsViewUiBinder uiBinder = GWT.create( ContactsViewUiBinder.class );

  @UiField
  FlexTable _contactsTable;
  @UiField
  Button _addButton;
  @UiField
  Button _deleteButton;

  private Presenter<T> _presenter;
  private List<ColumnDefinition<T>> _columnDefinitions;
  private List<T> _rowData;

  public ContactsViewUI()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  public void setPresenter( final Presenter<T> presenter )
  {
    _presenter = presenter;
  }

  public void setColumnDefinitions( final List<ColumnDefinition<T>> columnDefinitions )
  {
    _columnDefinitions = columnDefinitions;
  }

  public void setRowData( final List<T> rowData )
  {
    _contactsTable.removeAllRows();
    _rowData = rowData;

    for ( int i = 0; i < rowData.size(); ++i )
    {
      final T t = rowData.get( i );
      for ( int j = 0; j < _columnDefinitions.size(); ++j )
      {
        _contactsTable.setWidget( i, j, _columnDefinitions.get( j ).render( t ) );
      }
    }
  }

  @UiHandler("_addButton")
  void onAddButtonClicked( final ClickEvent event )
  {
    if ( _presenter != null )
    {
      _presenter.onAddButtonClicked();
    }
  }

  @UiHandler("_deleteButton")
  void onDeleteButtonClicked( final ClickEvent event )
  {
    if ( _presenter != null )
    {
      _presenter.onDeleteButtonClicked();
    }
  }

  @UiHandler("_contactsTable")
  void onTableClicked( final ClickEvent event )
  {
    if ( _presenter != null )
    {
      final HTMLTable.Cell cell = _contactsTable.getCellForEvent( event );
      if ( null != cell )
      {
        if ( shouldFireClickEvent( cell ) )
        {
          _presenter.onItemClicked( _rowData.get( cell.getRowIndex() ) );
        }

        if ( shouldFireSelectEvent( cell ) )
        {
          _presenter.onItemSelected( _rowData.get( cell.getRowIndex() ) );

        }
      }
    }
  }

  private boolean shouldFireClickEvent( final HTMLTable.Cell cell )
  {
    final ColumnDefinition<T> definition = _columnDefinitions.get( cell.getCellIndex() );
    if ( definition != null )
    {
      return definition.isClickable();
    }
    return false;
  }

  private boolean shouldFireSelectEvent( final HTMLTable.Cell cell )
  {
    final ColumnDefinition<T> definition = _columnDefinitions.get( cell.getCellIndex() );
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
