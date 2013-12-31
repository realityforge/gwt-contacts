package com.google.gwt.sample.contacts.server;

import javax.servlet.annotation.WebServlet;
import org.realityforge.gwt.appcache.server.AbstractManifestServlet;
import org.realityforge.gwt.appcache.server.propertyprovider.UserAgentPropertyProvider;

@WebServlet(urlPatterns = { "/contacts.appcache" })
public class ManifestServlet
  extends AbstractManifestServlet
{
  public ManifestServlet()
  {
    addPropertyProvider( new UserAgentPropertyProvider() );
    addPropertyProvider( new UIModalityPropertyProvider() );
  }
}
