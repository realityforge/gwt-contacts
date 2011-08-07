package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTMLTable;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;
import java.util.List;

public class ContactsViewUI
    extends Composite
    implements ContactsView
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

  private Presenter _presenter;
  private List<ContactDetails> _rowData;

  public ContactsViewUI()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  public void setPresenter( final Presenter presenter )
  {
    _presenter = presenter;
  }

  public void setRowData( final List<ContactDetails> rowData )
  {
    _contactsTable.removeAllRows();
    _rowData = rowData;

    for( int i = 0; i < rowData.size(); ++i )
    {
      final ContactDetails t = rowData.get( i );
      _contactsTable.setWidget( i, 0, new CheckBox() );
      _contactsTable.setWidget( i, 1, new Label( t.getDisplayName() ) );
    }
  }

  @UiHandler( "_addButton" )
  void onAddButtonClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      _presenter.onAddButtonClicked();
    }
  }

  @UiHandler( "_deleteButton" )
  void onDeleteButtonClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      _presenter.onDeleteButtonClicked();
    }
  }

  @UiHandler( "_contactsTable" )
  void onTableClicked( final ClickEvent event )
  {
    if( _presenter != null )
    {
      final HTMLTable.Cell cell = _contactsTable.getCellForEvent( event );
      if( null != cell )
      {

        if( 1 == cell.getCellIndex() )
        {
          _presenter.onItemClicked( _rowData.get( cell.getRowIndex() ) );
        }

        if( 0 == cell.getCellIndex() )
        {
          _presenter.onItemSelected( _rowData.get( cell.getRowIndex() ) );

        }
      }
    }
  }

  public Widget asWidget()
  {
    return this;
  }
}
