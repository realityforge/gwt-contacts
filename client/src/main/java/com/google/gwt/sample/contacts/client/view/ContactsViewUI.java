package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.user.client.ui.Widget;
import com.smartgwt.client.types.Alignment;
import com.smartgwt.client.types.SelectionType;
import com.smartgwt.client.widgets.Canvas;
import com.smartgwt.client.widgets.IButton;
import com.smartgwt.client.widgets.ImgButton;
import com.smartgwt.client.widgets.Label;
import com.smartgwt.client.widgets.events.ClickEvent;
import com.smartgwt.client.widgets.events.ClickHandler;
import com.smartgwt.client.widgets.grid.ListGrid;
import com.smartgwt.client.widgets.grid.ListGridField;
import com.smartgwt.client.widgets.grid.ListGridRecord;
import com.smartgwt.client.widgets.layout.VLayout;
import java.util.ArrayList;
import java.util.List;

public class ContactsViewUI
  extends ListGrid
  implements ContactsView
{
  private VLayout _layout;
  private ListGrid _contactsTable;

  private Presenter _presenter;

  public ContactsViewUI()
  {
    _layout = new VLayout( 15 );
    _layout.setAutoHeight();

    final IButton addButton = new IButton( "Add" );
    _layout.addMember( addButton );

    final IButton deleteButton = new IButton( "Delete" );
    _layout.addMember( deleteButton );

    _contactsTable = new ListGrid()
    {
      @Override
      protected Canvas createRecordComponent( final ListGridRecord record, final Integer column )
      {
        final ContactDetails contact = (ContactDetails) record.getAttributeAsObject( "object" );
        final String fieldName = this.getFieldName( column );
        if ( fieldName.equals( "checkBox" ) )
        {
          final ImgButton button = new ImgButton();
          button.setActionType( SelectionType.CHECKBOX );
          button.setSize( "1em", "1em" );
          button.setSrc( "person_open.png" );
          button.setShowDown( false );
          button.setShowRollOver( false );
          button.setLayoutAlign( Alignment.CENTER );
          button.setHeight( 16 );
          button.setWidth( 16 );

          button.addClickHandler( new ClickHandler()
          {
            @Override
            public void onClick( final ClickEvent event )
            {
              _presenter.onItemSelected( contact );
            }
          } );
          return button;
        }
        else
        {
          final Label name = new Label( record.getAttribute( "name" ) );
          name.setHeight( 16 );
          name.addClickHandler( new ClickHandler()
          {
            @Override
            public void onClick( final ClickEvent event )
            {
              _presenter.onItemClicked( contact );
            }
          } );
          return name;
        }
      }
    };
    _contactsTable.setWidth( 500 );
    _contactsTable.setHeight( 224 );
    _contactsTable.setEmptyCellValue( "--" );
    _contactsTable.setShowEmptyMessage( true );
    _contactsTable.setShowRecordComponents( true );
    _contactsTable.setShowRecordComponentsByCell( true );

    final ListGridField field0 = new ListGridField( "checkBox" );
    field0.setWidth( 100 );
    final ListGridField field1 = new ListGridField( "name" );
    _contactsTable.setShowHeader( false );
    _contactsTable.setFields( field0, field1 );
    _contactsTable.setSortField( 0 );
    _contactsTable.setDataPageSize( 50 );

    _layout.addMember( _contactsTable );

    addButton.addClickHandler( new ClickHandler()
    {
      @Override
      public void onClick( final com.smartgwt.client.widgets.events.ClickEvent event )
      {
        if ( _presenter != null )
        {
          _presenter.onAddButtonClicked();
        }
      }
    } );

    deleteButton.addClickHandler( new ClickHandler()
    {
      @Override
      public void onClick( final com.smartgwt.client.widgets.events.ClickEvent event )
      {
        if ( _presenter != null )
        {
          _presenter.onDeleteButtonClicked();
        }
      }
    } );
  }

  public void setPresenter( final Presenter presenter )
  {
    _presenter = presenter;
  }

  public void setRowData( final List<ContactDetails> rowData )
  {
    final ArrayList<ListGridRecord> records = new ArrayList<ListGridRecord>( rowData.size() );
    for ( final ContactDetails contact : rowData )
    {
      final ListGridRecord record = new ListGridRecord();
      record.setAttribute( "object", contact );
      record.setAttribute( "name", contact.getDisplayName() );
      records.add( record );
    }
    _contactsTable.setRecords( records.toArray( new ListGridRecord[ records.size() ] ) );
  }

  public Widget asWidget()
  {
    return _layout;
  }
}
