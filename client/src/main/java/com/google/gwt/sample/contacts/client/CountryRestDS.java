package com.google.gwt.sample.contacts.client;

import com.smartgwt.client.data.DSRequest;
import com.smartgwt.client.data.DSResponse;
import com.smartgwt.client.data.OperationBinding;
import com.smartgwt.client.data.RestDataSource;
import com.smartgwt.client.data.fields.DataSourceTextField;
import com.smartgwt.client.types.DSOperationType;
import com.smartgwt.client.types.DSProtocol;

public class CountryRestDS
  extends RestDataSource
{
  public CountryRestDS()
  {
    final OperationBinding fetch = new OperationBinding();
    fetch.setOperationType( DSOperationType.FETCH );
    fetch.setDataProtocol( DSProtocol.POSTMESSAGE );
    final OperationBinding add = new OperationBinding();
    add.setOperationType( DSOperationType.ADD );
    add.setDataProtocol( DSProtocol.POSTMESSAGE );
    final OperationBinding update = new OperationBinding();
    update.setOperationType( DSOperationType.UPDATE );
    update.setDataProtocol( DSProtocol.POSTMESSAGE );
    final OperationBinding remove = new OperationBinding();
    remove.setOperationType( DSOperationType.REMOVE );
    remove.setDataProtocol( DSProtocol.POSTMESSAGE );
    setOperationBindings( fetch, add, update, remove );

    final DataSourceTextField countryCode = new DataSourceTextField( "countryCode", "Code" );
    countryCode.setPrimaryKey( true );
    countryCode.setCanEdit( false );
    final DataSourceTextField countryName = new DataSourceTextField( "countryName", "Country" );
    final DataSourceTextField capital = new DataSourceTextField( "capital", "Capital" );

    setFields( countryCode, countryName, capital );
    setFetchDataURL( "ds/xml/responses/country_fetch_rest.xml" );
    setAddDataURL( "ds/xml/responses/country_add_rest.xml" );
    setUpdateDataURL( "ds/xml/responses/country_update_rest.xml" );
    setRemoveDataURL( "ds/xml/responses/country_remove_rest.xml" );

    setClientOnly( false );
  }
}
