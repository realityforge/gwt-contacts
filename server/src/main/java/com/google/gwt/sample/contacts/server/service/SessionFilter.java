package com.google.gwt.sample.contacts.server.service;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

@WebFilter( filterName = "SessionFilter", urlPatterns = "/*" )
public class SessionFilter
    implements Filter
{
  public void init( FilterConfig filterConfig )
      throws ServletException
  {
  }

  public void doFilter( ServletRequest request, ServletResponse response,
                        FilterChain chain )
      throws java.io.IOException, ServletException
  {
    final HttpServletRequest httpServletRequest = (HttpServletRequest) request;
    final HttpSession session = httpServletRequest.getSession();
    if( null == session )
    {
      httpServletRequest.getSession( true );
    }

    chain.doFilter( request, response );
  }

  public void destroy()
  {
  }
}