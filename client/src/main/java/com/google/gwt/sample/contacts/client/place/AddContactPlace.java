package com.google.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;
import com.google.gwt.place.shared.Prefix;

public class AddContactPlace
  extends Place
{
  @Prefix( value = "add" )
  public static class Tokenizer
    implements PlaceTokenizer<AddContactPlace>
  {
    @Override
    public String getToken( final AddContactPlace place )
    {
      return "";
    }

    @Override
    public AddContactPlace getPlace( final String token )
    {
      return new AddContactPlace();
    }
  }
}
