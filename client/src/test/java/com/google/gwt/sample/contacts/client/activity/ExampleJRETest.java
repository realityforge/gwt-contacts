package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.event.shared.SimpleEventBus;
import com.google.gwt.sample.contacts.client.data_type.contacts.ContactDetailsDTO;
import com.google.gwt.sample.contacts.client.data_type.contacts.ContactDetailsDTOFactory;
import com.google.gwt.sample.contacts.client.service.contacts.GwtRpcContactsService;
import com.google.gwt.sample.contacts.client.view.ListContactsView;
import java.util.ArrayList;
import java.util.List;
import org.easymock.IAnswer;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.realityforge.replicant.client.AsyncCallback;
import org.realityforge.replicant.client.AsyncErrorCallback;
import static org.easymock.EasyMock.createStrictMock;
import static org.easymock.EasyMock.expectLastCall;
import static org.easymock.EasyMock.getCurrentArguments;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

@SuppressWarnings( "unchecked" )
public class ExampleJRETest
{
  private ListContactsActivity _listContactsActivity;
  private GwtRpcContactsService _mockRpcService;
  private EventBus _mockEventBus;
  private ListContactsView _mockViewList;
  private List<ContactDetailsDTO> _contactDetails;

  @Before
  public void setUp()
  {
    _mockRpcService = createStrictMock( GwtRpcContactsService.class );
    _mockEventBus = new SimpleEventBus();
    _mockViewList = createStrictMock( ListContactsView.class );
    _listContactsActivity = new ListContactsActivity( _mockRpcService, _mockEventBus, _mockViewList );
  }

  @Test
  public void testDeleteButton()
  {
    _contactDetails = new ArrayList<ContactDetailsDTO>();
    _contactDetails.add( newContactDetails( "0", "type1", "1_contact" ) );
    _contactDetails.add( newContactDetails( "1", "type2", "2_contact" ) );
    _listContactsActivity.setContactDetails( _contactDetails );

    _mockRpcService.deleteContacts( isA( ArrayList.class ), isA( AsyncCallback.class ), isA( AsyncErrorCallback.class ) );

    expectLastCall().andAnswer( new IAnswer()
    {
      public Object answer()
        throws Throwable
      {
        final AsyncCallback callback = getCallback();
        callback.onSuccess( null );
        return null;
      }
    } );

    _mockRpcService.getContactDetails( isA( AsyncCallback.class ), isA( AsyncErrorCallback.class ) );
    expectLastCall().andAnswer( new IAnswer()
    {
      public Object answer()
        throws Throwable
      {
        final ArrayList<ContactDetailsDTO> results = new ArrayList<ContactDetailsDTO>();
        results.add( newContactDetails( "0", "type1", "1_contact" ) );
        getCallback().onSuccess( results );
        return null;
      }
    } );


    replay( _mockRpcService );
    _listContactsActivity.onDeleteButtonClicked();
    verify( _mockRpcService );

    Assert.assertEquals( 1, _listContactsActivity.getContactDetails().size() );
  }

  private ContactDetailsDTO newContactDetails( final String id, final String type, final String displayName )
  {
    return ContactDetailsDTOFactory.create( id, type, displayName );
  }

  private AsyncCallback getCallback()
  {
    final Object[] arguments = getCurrentArguments();
    return (AsyncCallback) arguments[ arguments.length - 2 ];
  }
}
