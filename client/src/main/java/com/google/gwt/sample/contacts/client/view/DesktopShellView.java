package com.google.gwt.sample.contacts.client.view;

import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.gwt.user.client.ui.IsWidget;

public interface DesktopShellView
    extends IsWidget
{
  AcceptsOneWidget getMasterRegion();

  AcceptsOneWidget getDetailRegion();
}
