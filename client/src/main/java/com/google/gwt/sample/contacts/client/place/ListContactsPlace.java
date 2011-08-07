package com.google.gwt.sample.contacts.client.place;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;

//public class HelloPlace extends ActivityPlace<HelloActivity>
public class ListContactsPlace extends Place
{
	private String helloName;

	public ListContactsPlace( String token )
	{
		this.helloName = token;
	}

	public String getHelloName()
	{
		return helloName;
	}

	public static class Tokenizer implements PlaceTokenizer<HelloPlace>
	{

		@Override
		public String getToken(HelloPlace place)
		{
			return place.getHelloName();
		}

		@Override
		public HelloPlace getPlace(String token)
		{
			return new HelloPlace(token);
		}

	}
	
//	@Override
//	protected Place getPlace(String token)
//	{
//		return new HelloPlace(token);
//	}
//
//	@Override
//	protected Activity getActivity()
//	{
//		return new HelloActivity("David");
//	}
}
