package com.google.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;
import com.google.gwt.place.shared.Prefix;

public class EditContactPlace
  extends Place
{
  private final String _id;

  public EditContactPlace( final String id )
  {
    _id = id;
  }

  public String getId()
  {
    return _id;
  }

  @Prefix( value = "edit" )
  public static class Tokenizer
    implements PlaceTokenizer<EditContactPlace>
  {
    @Override
    public String getToken( final EditContactPlace place )
    {
      return place.getId();
    }

    @Override
    public EditContactPlace getPlace( final String token )
    {
      return new EditContactPlace( token );
    }
  }
}
