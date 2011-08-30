package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.sample.contacts.client.common.SelectionModel;
import com.google.gwt.sample.contacts.client.event.AddContactEvent;
import com.google.gwt.sample.contacts.client.event.ShowContactEvent;
import com.google.gwt.sample.contacts.client.view.ListContactsView;
import com.google.gwt.sample.contacts.shared.ContactDetailsVO;
import com.google.gwt.sample.contacts.shared.ContactsServiceAsync;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import java.util.ArrayList;
import java.util.List;
import javax.inject.Inject;

public class ListContactsActivity
  extends AbstractActivity
  implements ListContactsView.Presenter
{
  private final ContactsServiceAsync _rpcService;
  private final EventBus _eventBus;
  private final ListContactsView _view;
  private final SelectionModel<ContactDetailsVO> _selectionModel;

  private List<ContactDetailsVO> _contactDetails;

  @Inject
  public ListContactsActivity( final ContactsServiceAsync rpcService,
                               final EventBus eventBus,
                               final ListContactsView view )
  {
    _rpcService = rpcService;
    _eventBus = eventBus;
    _view = view;
    _selectionModel = new SelectionModel<ContactDetailsVO>();
  }

  @Override
  public void start( final AcceptsOneWidget panel, final EventBus eventBus )
  {
    _view.setPresenter( this );
    panel.setWidget( _view.asWidget() );
    fetchContactDetails();
  }

  public void onAddButtonClicked()
  {
    _eventBus.fireEvent( new AddContactEvent() );
  }

  public void onDeleteButtonClicked()
  {
    deleteSelectedContacts();
  }

  public void onItemClicked( final ContactDetailsVO contactDetails )
  {
    _eventBus.fireEvent( new ShowContactEvent( contactDetails.getId() ) );
  }

  public void onItemSelected( final ContactDetailsVO contactDetails )
  {
    if ( _selectionModel.isSelected( contactDetails ) )
    {
      _selectionModel.removeSelection( contactDetails );
    }
    else
    {
      _selectionModel.addSelection( contactDetails );
    }
  }

  public void sortContactDetails()
  {
    // Yes, we could use a more optimized method of sorting, but the
    //  point is to create a test case that helps illustrate the higher
    //  level concepts used when creating MVP-based applications.
    //
    final int size = _contactDetails.size();
    for ( int i = 0; i < size; ++i )
    {
      for ( int j = 0; j < size - 1; ++j )
      {
        if ( _contactDetails.get( j )
               .getDisplayName()
               .compareToIgnoreCase( _contactDetails.get( j + 1 ).getDisplayName() ) >= 0 )
        {
          final ContactDetailsVO tmp = _contactDetails.get( j );
          _contactDetails.set( j, _contactDetails.get( j + 1 ) );
          _contactDetails.set( j + 1, tmp );
        }
      }
    }
  }

  public void setContactDetails( final List<ContactDetailsVO> contactDetails )
  {
    this._contactDetails = contactDetails;
    sortContactDetails();
  }

  public List<ContactDetailsVO> getContactDetails()
  {
    return _contactDetails;
  }

  private void fetchContactDetails()
  {
    _rpcService.getContactDetails( new AsyncCallback<ArrayList<ContactDetailsVO>>()
    {
      public void onSuccess( final ArrayList<ContactDetailsVO> result )
      {
        setContactDetails( result );
        _view.setRowData( _contactDetails );
      }

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error fetching contact details" );
      }
    } );
  }

  private void deleteSelectedContacts()
  {
    final List<ContactDetailsVO> selectedContacts = _selectionModel.getSelectedItems();
    final ArrayList<String> ids = new ArrayList<String>();

    for ( final ContactDetailsVO selected : selectedContacts )
    {
      ids.add( selected.getId() );
    }

    _rpcService.deleteContacts( ids, new AsyncCallback<Void>()
    {
      public void onSuccess( final Void result )
      {
        fetchContactDetails();
        _selectionModel.clear();
      }

      public void onFailure( final Throwable caught )
      {
        System.out.println( "Error deleting selected contacts" );
      }
    } );
  }
}
