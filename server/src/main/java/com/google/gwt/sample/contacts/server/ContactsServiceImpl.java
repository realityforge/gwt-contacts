package com.google.gwt.sample.contacts.server;

import com.google.gwt.sample.contacts.shared.ContactVO;
import com.google.gwt.sample.contacts.shared.ContactDetailsVO;
import com.google.gwt.sample.contacts.shared.ContactsService;
import com.google.gwt.user.server.rpc.XsrfProtectedServiceServlet;
import java.util.ArrayList;
import javax.ejb.EJB;
import javax.servlet.annotation.WebServlet;

@SuppressWarnings( "serial" )
@WebServlet( urlPatterns = { ModuleInfo.PREFIX + ContactsService.PATH } )
public class ContactsServiceImpl
  extends XsrfProtectedServiceServlet
  implements ContactsService
{
  @EJB
  private Contacts _contacts;

  public ContactVO createOrUpdateContact( final ContactVO contact )
  {
    return _contacts.createOrUpdateContact( contact );
  }

  public void deleteContacts( final ArrayList<String> ids )
  {
    _contacts.deleteContacts( ids );
  }

  public ArrayList<ContactDetailsVO> getContactDetails()
  {
    return _contacts.getContactDetails();
  }

  public ContactVO getContact( final String id )
  {
    return _contacts.getContact( id );
  }
}
