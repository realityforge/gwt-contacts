package com.google.gwt.sample.contacts.client.common;

import java.util.ArrayList;
import java.util.List;

public class SelectionModel<T>
{
  private final List<T> _selectedItems = new ArrayList<T>();

  public List<T> getSelectedItems()
  {
    return _selectedItems;
  }

  public void addSelection( final T item )
  {
    _selectedItems.add( item );
  }

  public void removeSelection( final T item )
  {
    _selectedItems.remove( item );
  }

  public boolean isSelected( final T item )
  {
    return _selectedItems.contains( item );
  }

  public void clear()
  {
    _selectedItems.clear();
  }
}
