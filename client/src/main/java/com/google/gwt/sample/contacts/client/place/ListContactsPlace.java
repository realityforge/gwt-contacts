package com.google.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;

public class ListContactsPlace
  extends Place
{
  public static class Tokenizer
    implements PlaceTokenizer<ListContactsPlace>
  {
    public String getToken( final ListContactsPlace place )
    {
      return null;
    }

    public ListContactsPlace getPlace( final String token )
    {
      return new ListContactsPlace();
    }

  }
}
