package org.realityforge.gwt.sample.contacts.client.view.ui;

import org.realityforge.gwt.sample.contacts.client.view.PhoneShellView;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;

public class PhoneShellUI
  implements PhoneShellView
{
  private final SimplePanel _display = new SimplePanel();

  public AcceptsOneWidget getRegion()
  {
    return _display;
  }

  public Widget asWidget()
  {
    return _display;
  }
}
