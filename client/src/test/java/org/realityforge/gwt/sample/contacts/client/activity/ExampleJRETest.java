package org.realityforge.gwt.sample.contacts.client.activity;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.event.shared.SimpleEventBus;
import org.realityforge.gwt.sample.contacts.client.data_type.contacts.ContactDetailsDTO;
import org.realityforge.gwt.sample.contacts.client.data_type.contacts.ContactDetailsDTOFactory;
import org.realityforge.gwt.sample.contacts.client.service.contacts.GwtRpcContactsService;
import org.realityforge.gwt.sample.contacts.client.view.ListContactsView;
import java.util.ArrayList;
import java.util.List;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;
import org.realityforge.replicant.client.AsyncCallback;
import org.realityforge.replicant.client.AsyncErrorCallback;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;
import static org.mockito.Mockito.*;
import static org.testng.Assert.*;

@SuppressWarnings("unchecked")
public class ExampleJRETest
{
  private ListContactsActivity _listContactsActivity;
  private GwtRpcContactsService _mockRpcService;
  private EventBus _mockEventBus;
  private ListContactsView _mockViewList;
  private List<ContactDetailsDTO> _contactDetails;

  @BeforeMethod
  public void setUp()
  {
    _mockRpcService = mock( GwtRpcContactsService.class );
    _mockEventBus = new SimpleEventBus();
    _mockViewList = mock( ListContactsView.class );
    _listContactsActivity = new ListContactsActivity( _mockRpcService, _mockEventBus, _mockViewList );
  }

  @Test
  public void testDeleteButton()
  {
    _contactDetails = new ArrayList<ContactDetailsDTO>();
    _contactDetails.add( newContactDetails( "0", "type1", "1_contact" ) );
    _contactDetails.add( newContactDetails( "1", "type2", "2_contact" ) );
    _listContactsActivity.setContactDetails( _contactDetails );

    doAnswer( new Answer<Void>()
    {
      @Override
      public Void answer( final InvocationOnMock invocation )
        throws Throwable
      {
        final AsyncCallback callback = (AsyncCallback) invocation.getArguments()[ 1 ];
        callback.onSuccess( null );
        return null;
      }
    } ).when( _mockRpcService ).deleteContacts( anyList(),
                                                any( AsyncCallback.class ),
                                                any( AsyncErrorCallback.class ) );

    doAnswer( new Answer<Void>()
    {
      @Override
      public Void answer( final InvocationOnMock invocation )
        throws Throwable
      {
        final ArrayList<ContactDetailsDTO> results = new ArrayList<ContactDetailsDTO>();
        results.add( newContactDetails( "0", "type1", "1_contact" ) );
        final AsyncCallback callback = (AsyncCallback) invocation.getArguments()[ 0 ];
        callback.onSuccess( results );
        return null;
      }
    } ).
      when( _mockRpcService ).
      getContactDetails( any( AsyncCallback.class ), any( AsyncErrorCallback.class ) );


    _listContactsActivity.onDeleteButtonClicked();
    verify( _mockRpcService );

    assertEquals( 1, _listContactsActivity.getContactDetails().size() );
  }

  private ContactDetailsDTO newContactDetails( final String id, final String type, final String displayName )
  {
    return ContactDetailsDTOFactory.create( id, type, displayName );
  }
}
