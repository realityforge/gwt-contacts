package com.google.gwt.sample.contacts.client.gin;

import com.google.gwt.place.shared.PlaceHistoryMapper;
import com.google.gwt.place.shared.WithTokenizers;
import com.google.gwt.sample.contacts.client.place.AddContactPlace;
import com.google.gwt.sample.contacts.client.place.EditContactPlace;
import com.google.gwt.sample.contacts.client.place.ListContactsPlace;

/**
 * PlaceHistoryMapper interface is used to attach all places which the
 * PlaceHistoryHandler should be aware of. This is done via the @WithTokenizers
 * annotation or by extending PlaceHistoryMapperWithFactory and creating a
 * separate TokenizerFactory.
 */
@WithTokenizers( { ListContactsPlace.Tokenizer.class, EditContactPlace.Tokenizer.class, AddContactPlace.Tokenizer.class } )
public interface ApplicationPlaceHistoryMapper
  extends PlaceHistoryMapper
{
}
