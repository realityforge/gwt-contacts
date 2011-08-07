package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratorPanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HasValue;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

public class EditContactUI
    extends Composite
    implements EditContactView
{
  private final TextBox _firstName;
  private final TextBox _lastName;
  private final TextBox _emailAddress;
  private final FlexTable _detailsTable;
  private Presenter _presenter;

  public EditContactUI()
  {
    final DecoratorPanel contentDetailsDecorator = new DecoratorPanel();
    contentDetailsDecorator.setWidth( "18em" );
    initWidget( contentDetailsDecorator );

    final VerticalPanel contentDetailsPanel = new VerticalPanel();
    contentDetailsPanel.setWidth( "100%" );

    // Create the contacts list
    //
    _detailsTable = new FlexTable();
    _detailsTable.setCellSpacing( 0 );
    _detailsTable.setWidth( "100%" );
    _detailsTable.addStyleName( "contacts-ListContainer" );
    _detailsTable.getColumnFormatter().addStyleName( 1, "add-contact-input" );
    _firstName = new TextBox();
    _lastName = new TextBox();
    _emailAddress = new TextBox();
    initDetailsTable();
    contentDetailsPanel.add( _detailsTable );

    final HorizontalPanel menuPanel = new HorizontalPanel();
    final Button saveButton = new Button( "Save" );
    final Button cancelButton = new Button( "Cancel" );
    menuPanel.add( saveButton );
    menuPanel.add( cancelButton );
    contentDetailsPanel.add( menuPanel );
    contentDetailsDecorator.add( contentDetailsPanel );

    saveButton.addClickHandler( new ClickHandler()
    {
      public void onClick( final ClickEvent clickEvent )
      {
        if( _presenter != null )
        {
          _presenter.onSaveButtonClicked();
        }
      }
    } );

    cancelButton.addClickHandler( new ClickHandler()
    {
      public void onClick( final ClickEvent clickEvent )
      {
        if( _presenter != null )
        {
          _presenter.onCancelButtonClicked();
        }
      }
    } );
  }

  private void initDetailsTable()
  {
    _detailsTable.setWidget( 0, 0, new Label( "Firstname" ) );
    _detailsTable.setWidget( 0, 1, _firstName );
    _detailsTable.setWidget( 1, 0, new Label( "Lastname" ) );
    _detailsTable.setWidget( 1, 1, _lastName );
    _detailsTable.setWidget( 2, 0, new Label( "Email Address" ) );
    _detailsTable.setWidget( 2, 1, _emailAddress );
    _firstName.setFocus( true );
  }

  public void setPresenter( final Presenter presenter )
  {
    _presenter = presenter;
  }

  public HasValue<String> getFirstName()
  {
    return _firstName;
  }

  public HasValue<String> getLastName()
  {
    return _lastName;
  }

  public HasValue<String> getEmailAddress()
  {
    return _emailAddress;
  }

  public Widget asWidget()
  {
    return this;
  }
}
