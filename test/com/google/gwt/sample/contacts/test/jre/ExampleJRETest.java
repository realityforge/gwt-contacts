package com.google.gwt.sample.contacts.test.jre;

import com.google.gwt.sample.contacts.client.ContactsServiceAsync;
import com.google.gwt.sample.contacts.client.presenter.ContactsPresenter;
import com.google.gwt.sample.contacts.client.view.ContactsView;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.sample.contacts.client.common.ContactsColumnDefinitionsFactory;

import com.google.gwt.event.shared.HandlerManager;
import com.google.gwt.user.client.rpc.AsyncCallback;

import java.util.ArrayList;
import java.util.List;

import junit.framework.TestCase;

import static org.easymock.EasyMock.*;

import org.easymock.*;

public class ExampleJRETest extends TestCase {

  private ContactsPresenter contactsPresenter;
  private ContactsServiceAsync mockRpcService;
  private HandlerManager mockEventBus;
  private ContactsView<ContactDetails> mockView;
  private List<ContactDetails> contactDetails;

  @SuppressWarnings("unchecked")
  protected void setUp() {
    mockRpcService = createStrictMock(ContactsServiceAsync.class);
    mockEventBus = new HandlerManager(null);
    mockView = createStrictMock(ContactsView.class);
    contactsPresenter = new ContactsPresenter(mockRpcService, mockEventBus, 
        mockView, 
        ContactsColumnDefinitionsFactory.getTestContactsColumnDefinitions());
  }
  
  @SuppressWarnings("unchecked")
  public void testDeleteButton() {
    contactDetails = new ArrayList<ContactDetails>();
    contactDetails.add(new ContactDetails("0", "c_contact"));
    contactsPresenter.setContactDetails(contactDetails);
    
    mockRpcService.deleteContacts(isA(ArrayList.class), 
        isA(AsyncCallback.class));
    
    expectLastCall().andAnswer(new IAnswer() {
      public Object answer() throws Throwable {
        final Object[] arguments = getCurrentArguments();
        AsyncCallback callback =
                (AsyncCallback) arguments[arguments.length - 1];
        callback.onSuccess(new ArrayList<ContactDetails>());
        return null;
      }
    });
    
    replay(mockRpcService);
    contactsPresenter.onDeleteButtonClicked();
    verify(mockRpcService);
    
    List<ContactDetails> updatedContactDetails = 
      contactsPresenter.getContactDetails();
    
    assertEquals(0, updatedContactDetails.size());
    
  }
}
