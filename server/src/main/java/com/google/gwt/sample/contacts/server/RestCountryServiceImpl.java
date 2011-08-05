package com.google.gwt.sample.contacts.server;

import java.io.IOException;
import java.util.Enumeration;
import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings( "serial" )
@WebServlet( urlPatterns = { "/ds/xml/responses/country_fetch_rest.xml" } )
public class RestCountryServiceImpl
  extends HttpServlet
{
  @Override
  protected void doGet( final HttpServletRequest req, final HttpServletResponse resp )
    throws ServletException, IOException
  {
    System.out.println( "RestCountryServiceImpl.doGet" );
    final Enumeration headers = req.getHeaderNames();
    while ( headers.hasMoreElements() )
    {
      final String s = (String) headers.nextElement();
      System.out.println( s + " = " + req.getHeader( s ) );
    }
    final ServletInputStream inputStream = req.getInputStream();
    final StringBuilder sb = new StringBuilder();
    while ( inputStream.available() > 0 )
    {
      sb.append( (char) inputStream.read() );
    }
    System.out.println( sb );
    super.doGet( req, resp );
  }
}
