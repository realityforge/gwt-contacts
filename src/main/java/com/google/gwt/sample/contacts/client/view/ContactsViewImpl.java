package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Document;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.EventTarget;
import com.google.gwt.dom.client.Node;
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
import com.google.gwt.user.client.ui.HTML;
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

  private static final ContactsViewUiBinder uiBinder =
    GWT.create( ContactsViewUiBinder.class );

  @UiField
  HTML contactsTable;
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
    this.rowData = rowData;

    final TableElement table = Document.get().createTableElement();
    final TableSectionElement tbody;
    table.appendChild( tbody = Document.get().createTBodyElement() );

    for ( final T rowDatum : rowData )
    {
      final TableRowElement row = tbody.insertRow( -1 );
      for ( final ColumnDefinition<T> columnDefinition : columnDefinitions )
      {
        final TableCellElement cell = row.insertCell( -1 );
        final StringBuilder sb = new StringBuilder();
        columnDefinition.render( rowDatum, sb );
        cell.setInnerHTML( sb.toString() );

        // TODO: Really total hack! There's gotta be a better way...
        final Element child = cell.getFirstChildElement();
        if ( child != null )
        {
          Event.sinkEvents( child, Event.ONFOCUS | Event.ONBLUR );
        }
      }
    }

    contactsTable.setHTML( table.getInnerHTML() );
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

  private TableCellElement findNearestParentCell( Node node )
  {
    while ( ( node != null ) )
    {
      if ( Element.is( node ) )
      {
        final Element elem = Element.as( node );

        final String tagName = elem.getTagName();
        if ( "td".equalsIgnoreCase( tagName ) || "th".equalsIgnoreCase( tagName ) )
        {
          return elem.cast();
        }
      }
      node = node.getParentNode();
    }
    return null;
  }


  @UiHandler( "contactsTable" )
  void onTableClicked( final ClickEvent event )
  {
    if ( presenter != null )
    {
      final EventTarget target = event.getNativeEvent().getEventTarget();
      final Node node = Node.as( target );
      final TableCellElement cell = findNearestParentCell( node );
      if ( null == cell )
      {
        return;
      }

      final TableRowElement tr = TableRowElement.as( cell.getParentElement() );
      final int row = tr.getSectionRowIndex();

      if ( shouldFireClickEvent( cell ) )
      {
        presenter.onItemClicked( rowData.get( row ) );
      }
      if ( shouldFireSelectEvent( cell ) )
      {
        presenter.onItemSelected( rowData.get( row ) );
      }
    }
  }

  private boolean shouldFireClickEvent( final TableCellElement cell )
  {
    boolean shouldFireClickEvent = false;

    if ( cell != null )
    {
      final ColumnDefinition<T> columnDefinition =
        columnDefinitions.get( cell.getCellIndex() );

      if ( columnDefinition != null )
      {
        shouldFireClickEvent = columnDefinition.isClickable();
      }
    }

    return shouldFireClickEvent;
  }

  private boolean shouldFireSelectEvent( final TableCellElement cell )
  {
    boolean shouldFireSelectEvent = false;

    if ( cell != null )
    {
      final ColumnDefinition<T> columnDefinition =
        columnDefinitions.get( cell.getCellIndex() );

      if ( columnDefinition != null )
      {
        shouldFireSelectEvent = columnDefinition.isSelectable();
      }
    }

    return shouldFireSelectEvent;
  }

  public Widget asWidget()
  {
    return this;
  }
}
