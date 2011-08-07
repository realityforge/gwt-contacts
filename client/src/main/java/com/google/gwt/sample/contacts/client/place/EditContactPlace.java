package com.google.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;

public class EditContactPlace extends Place
{
  public static class Tokenizer
      implements PlaceTokenizer<EditContactPlace>
  {
    @Override
    public String getToken( EditContactPlace place )
    {
      return null;
    }

    @Override
    public EditContactPlace getPlace( String token )
    {
      return new EditContactPlace();
    }

  }
}
