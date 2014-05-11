package org.realityforge.gwt.sample.contacts.client.activity;

import com.google.gwt.activity.shared.AbstractActivity;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import java.util.ArrayList;
import java.util.List;
import javax.inject.Inject;
import org.realityforge.gwt.sample.contacts.client.common.SelectionModel;
import org.realityforge.gwt.sample.contacts.client.data_type.ContactDetailsDTO;
import org.realityforge.gwt.sample.contacts.client.event.AddContactEvent;
import org.realityforge.gwt.sample.contacts.client.event.ShowContactEvent;
import org.realityforge.gwt.sample.contacts.client.service.ContactsAsyncCallback;
import org.realityforge.gwt.sample.contacts.client.service.ContactsAsyncErrorCallback;
import org.realityforge.gwt.sample.contacts.client.service.ContactsService;
import org.realityforge.gwt.sample.contacts.client.view.ListContactsView;

public class ListContactsActivity
  extends AbstractActivity
  implements ListContactsView.Presenter
{
  private final ContactsService _rpcService;
  private final EventBus _eventBus;
  private final ListContactsView _view;
  private final SelectionModel<ContactDetailsDTO> _selectionModel;

  private List<ContactDetailsDTO> _contactDetails;

  @Inject
  public ListContactsActivity( final ContactsService rpcService,
                               final EventBus eventBus,
                               final ListContactsView view )
  {
    _rpcService = rpcService;
    _eventBus = eventBus;
    _view = view;
    _selectionModel = new SelectionModel<ContactDetailsDTO>();
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

  public void onItemClicked( final ContactDetailsDTO contactDetails )
  {
    _eventBus.fireEvent( new ShowContactEvent( contactDetails.getID() ) );
  }

  public void onItemSelected( final ContactDetailsDTO contactDetails )
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
        final ContactDetailsDTO current = _contactDetails.get( j );
        final ContactDetailsDTO last = _contactDetails.get( j + 1 );
        if ( current.getDisplayName().compareToIgnoreCase( last.getDisplayName() ) >= 0 )
        {
          _contactDetails.set( j, last );
          _contactDetails.set( j + 1, current );
        }
      }
    }
  }

  public void setContactDetails( final List<ContactDetailsDTO> contactDetails )
  {
    _contactDetails = contactDetails;
    sortContactDetails();
  }

  public List<ContactDetailsDTO> getContactDetails()
  {
    return _contactDetails;
  }

  private void fetchContactDetails()
  {
    final ContactsAsyncCallback<List<ContactDetailsDTO>> success = new ContactsAsyncCallback<List<ContactDetailsDTO>>()
    {
      public void onSuccess( final List<ContactDetailsDTO> result )
      {
        setContactDetails( result );
        _view.setRowData( _contactDetails );
      }
    };
    final ContactsAsyncErrorCallback errorCallback = new ContactsAsyncErrorCallback()
    {
      @Override

      public void onFailure( final Throwable caught )
      {
        Window.alert( "Error fetching contact details" );
      }
    };
    _rpcService.getContactDetails( success, errorCallback );
  }

  private void deleteSelectedContacts()
  {
    final List<ContactDetailsDTO> selectedContacts = _selectionModel.getSelectedItems();
    final ArrayList<String> ids = new ArrayList<String>();

    for ( final ContactDetailsDTO selected : selectedContacts )
    {
      ids.add( selected.getID() );
    }

    final ContactsAsyncCallback<Void> success = new ContactsAsyncCallback<Void>()
    {
      public void onSuccess( final Void result )
      {
        fetchContactDetails();
        _selectionModel.clear();
      }
    };
    final ContactsAsyncErrorCallback errorCallback = new ContactsAsyncErrorCallback()
    {
      @Override
      public void onFailure( final Throwable caught )
      {
        System.out.println( "Error deleting selected contacts" );
      }
    };
    _rpcService.deleteContacts( ids, success, errorCallback );
  }
}
