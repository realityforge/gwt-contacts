package com.google.gwt.sample.contacts.client.view.ui;

import com.google.gwt.core.client.GWT;
import com.google.gwt.sample.contacts.client.view.DesktopShellView;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.Widget;

public class DesktopShellUI
  extends Composite
  implements DesktopShellView
{
  interface Binder extends UiBinder<Widget, DesktopShellUI> {}

  private static final Binder uiBinder = GWT.create( Binder.class );
  @UiField
  SimplePanel _detailsPanel;
  @UiField
  SimplePanel _masterPanel;

  public DesktopShellUI()
  {
    initWidget( uiBinder.createAndBindUi( this ) );
  }

  public AcceptsOneWidget getMasterRegion()
  {
    return _masterPanel;
  }

  public AcceptsOneWidget getDetailRegion()
  {
    return _detailsPanel;
  }

  public Widget asWidget()
  {
    return this;
  }
}
