package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.sample.contacts.client.view.DesktopShellView;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;

public class DesktopShellUI
  implements DesktopShellView
{
  private final SimplePanel _display = new SimplePanel();

  public AcceptsOneWidget getMasterRegion()
  {
    return _display;
  }

  public Widget asWidget()
  {
    return _display;
  }
}
