package com.google.gwt.sample.contacts.server;

import javax.servlet.http.HttpServletRequest;
import org.realityforge.gwt.appcache.server.propertyprovider.PropertyProvider;

public class UIModalityPropertyProvider
  implements PropertyProvider
{
  @Override
  public String getPropertyValue( final HttpServletRequest request )
  {
    final String userAgent = request.getHeader( "User-Agent" ).toLowerCase();
    if ( userAgent.contains( "android" ) || userAgent.contains( "phone" ) )
    {
      return "phone";
    }
    else if ( userAgent.contains( "ipad" ) )
    {
      return "tablet";
    }
    else
    {
      return "desktop";
    }
  }

  @Override
  public String getPropertyName()
  {
    return "ui.modality";
  }
}
