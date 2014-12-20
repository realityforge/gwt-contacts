package org.realityforge.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;
import com.google.gwt.place.shared.Prefix;

public class ListContactsPlace
  extends Place
{
  @Prefix( value = "list" )
  public static class Tokenizer
    implements PlaceTokenizer<ListContactsPlace>
  {
    public String getToken( final ListContactsPlace place )
    {
      return "";
    }

    public ListContactsPlace getPlace( final String token )
    {
      return new ListContactsPlace();
    }
  }
}
