package com.google.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;
import com.google.gwt.place.shared.Prefix;

public class ShowContactPlace
  extends Place
{
  private final String _id;

  public ShowContactPlace( final String id )
  {
    _id = id;
  }

  public String getId()
  {
    return _id;
  }

  @Prefix( value = "show" )
  public static class Tokenizer
    implements PlaceTokenizer<ShowContactPlace>
  {
    @Override
    public String getToken( final ShowContactPlace place )
    {
      return place.getId();
    }

    @Override
    public ShowContactPlace getPlace( final String token )
    {
      return new ShowContactPlace( token );
    }
  }
}
