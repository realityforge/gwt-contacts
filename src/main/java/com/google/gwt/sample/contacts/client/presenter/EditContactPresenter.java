package com.google.gwt.sample.contacts.client.presenter;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.dom.client.HasClickHandlers;
import com.google.gwt.event.shared.HandlerManager;
import com.google.gwt.sample.contacts.client.ContactsServiceAsync;
import com.google.gwt.sample.contacts.client.event.ContactUpdatedEvent;
import com.google.gwt.sample.contacts.client.event.EditContactCancelledEvent;
import com.google.gwt.sample.contacts.shared.Contact;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.HasValue;
import com.google.gwt.user.client.ui.HasWidgets;
import com.google.gwt.user.client.ui.Widget;

public class EditContactPresenter
  implements Presenter
{
  public interface Display
  {
    HasClickHandlers getSaveButton();

    HasClickHandlers getCancelButton();

    HasValue<String> getFirstName();

    HasValue<String> getLastName();

    HasValue<String> getEmailAddress();

    Widget asWidget();
  }

  private Contact contact;
  private final ContactsServiceAsync rpcService;
  private final HandlerManager eventBus;
  private final Display display;

  public EditContactPresenter( final ContactsServiceAsync rpcService,
                               final HandlerManager eventBus,
                               final Display display )
  {
    this.rpcService = rpcService;
    this.eventBus = eventBus;
    this.contact = new Contact();
    this.display = display;
    bind();
  }

  public EditContactPresenter( final ContactsServiceAsync rpcService,
                               final HandlerManager eventBus,
                               final Display display,
                               final String id )
  {
    this.rpcService = rpcService;
    this.eventBus = eventBus;
    this.display = display;
    bind();

    rpcService.getContact( id, new AsyncCallback<Contact>()
    {
      public void onSuccess( final Contact result )
      {
        contact = result;
        EditContactPresenter.this.display.getFirstName().setValue( contact.getFirstName() );
        EditContactPresenter.this.display.getLastName().setValue( contact.getLastName() );
        EditContactPresenter.this.display.getEmailAddress().setValue( contact.getEmailAddress() );
      }

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error retrieving contact" );
      }
    } );

  }

  public void bind()
  {
    this.display.getSaveButton().addClickHandler( new ClickHandler()
    {
      public void onClick( final ClickEvent event )
      {
        doSave();
      }
    } );

    this.display.getCancelButton().addClickHandler( new ClickHandler()
    {
      public void onClick( final ClickEvent event )
      {
        eventBus.fireEvent( new EditContactCancelledEvent() );
      }
    } );
  }

  public void go( final HasWidgets container )
  {
    container.clear();
    container.add( display.asWidget() );
  }

  private void doSave()
  {
    contact.setFirstName( display.getFirstName().getValue() );
    contact.setLastName( display.getLastName().getValue() );
    contact.setEmailAddress( display.getEmailAddress().getValue() );

    rpcService.createOrUpdateContact( contact, new AsyncCallback<Contact>()
    {
      public void onSuccess( final Contact result )
      {
        eventBus.fireEvent( new ContactUpdatedEvent( result ) );
      }

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error updating contact" );
      }
    } );
  }
}
