package com.google.gwt.sample.contacts.client.activity;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.event.shared.SimpleEventBus;
import com.google.gwt.sample.contacts.client.data_type.ContactsFactory;
import com.google.gwt.sample.contacts.client.data_type.contacts.ContactDetailsDTO;
import com.google.gwt.sample.contacts.client.service.contacts.ContactsService;
import com.google.gwt.sample.contacts.client.view.ListContactsView;
import com.google.web.bindery.autobean.vm.AutoBeanFactorySource;
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
  private ContactsService _mockRpcService;
  private EventBus _mockEventBus;
  private ListContactsView _mockViewList;
  private List<ContactDetailsDTO> _contactDetails;
  private ContactsFactory _factory;

  @Before
  public void setUp()
  {
    _mockRpcService = createStrictMock( ContactsService.class );
    _mockEventBus = new SimpleEventBus();
    _factory = AutoBeanFactorySource.create( ContactsFactory.class );
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
    final ContactDetailsDTO contactDetails = _factory.createContactDetailsDTO().as();
    contactDetails.setID( id );
    contactDetails.setType( type );
    contactDetails.setDisplayName( displayName );
    return contactDetails;
  }

  private AsyncCallback getCallback()
  {
    final Object[] arguments = getCurrentArguments();
    return (AsyncCallback) arguments[ arguments.length - 2 ];
  }
}
