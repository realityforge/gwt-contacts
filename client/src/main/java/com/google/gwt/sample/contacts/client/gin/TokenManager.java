package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.user.client.rpc.XsrfToken;

/** A utility class to manage access to the xsrf token. */
public class TokenManager
{
  public static XsrfToken _xsrfToken;

  public static XsrfToken getXsrfToken()
  {
    return _xsrfToken;
  }

  public static void setXsrfToken( final XsrfToken xsrfToken )
  {
    _xsrfToken = xsrfToken;
  }
}
