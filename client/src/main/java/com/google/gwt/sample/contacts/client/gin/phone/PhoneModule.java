package com.google.gwt.sample.contacts.client.gin.phone;

import com.google.gwt.inject.client.AbstractGinModule;
import com.google.gwt.sample.contacts.client.application.phone.PhoneActivityMapper;
import com.google.gwt.sample.contacts.client.view.PhoneShellView;
import com.google.gwt.sample.contacts.client.view.ui.PhoneShellUI;
import javax.inject.Singleton;

public class PhoneModule
  extends AbstractGinModule
{
  protected void configure()
  {
    bind( PhoneShellView.class ).to( PhoneShellUI.class ).in( Singleton.class );
    bind( PhoneActivityMapper.class ).in( Singleton.class );
  }
}
