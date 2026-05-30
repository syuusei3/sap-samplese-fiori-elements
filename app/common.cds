/*
 Common Annotations shared by all apps (sales orders / inventory domain).
*/

using { sap.capire.salesorders as my } from '../db/schema';
using { sap.common } from '@sap/cds/common';
using { sap.common.Currencies } from '../db/currencies';

////////////////////////////////////////////////////////////////////////////
//
//  Sales Orders — list
//
annotate my.SalesOrders with @(
  Common.SemanticKey : [ID],
  UI                 : {
    Identification  : [{ Value: orderNo }],
    SelectionFields : [
      orderNo,
      orderDate,
      customer_ID,
      salesOrg_code,
      status,
      currency_code
    ],
    LineItem        : [
      { Value: orderNo,           Label: '{i18n>OrderNo}' },
      { Value: orderDate,         Label: '{i18n>OrderDate}' },
      { Value: customer_ID,       Label: '{i18n>Customer}' },
      { Value: salesOrg_code,     Label: '{i18n>SalesOrg}' },
      { Value: status,            Label: '{i18n>Status}' },
      { Value: grossAmount,       Label: '{i18n>GrossAmount}' },
      { Value: currency.symbol,   Label: '{i18n>Currency}' },
    ]
  }
) {
  ID @Common: {
    SemanticObject  : 'SalesOrder',
    Text            : orderNo,
    TextArrangement : #TextOnly
  };
  customer @ValueList.entity : 'Customers';
  salesOrg @ValueList.entity : 'SalesOrgs';
};

////////////////////////////////////////////////////////////////////////////
//
//  Sales Order — header info
//
annotate my.SalesOrders with @(UI : {HeaderInfo : {
  TypeName       : '{i18n>SalesOrder}',
  TypeNamePlural : '{i18n>SalesOrders}',
  Title          : { Value: orderNo },
  Description    : { Value: customer.name }
}, });

////////////////////////////////////////////////////////////////////////////
//
//  Sales Order — element titles
//
annotate my.SalesOrders with {
  ID          @title: '{i18n>ID}';
  orderNo     @title: '{i18n>OrderNo}';
  orderDate   @title: '{i18n>OrderDate}';
  customer    @title: '{i18n>Customer}'  @Common: { Text: customer.name, TextArrangement: #TextOnly };
  salesOrg    @title: '{i18n>SalesOrg}'  @Common: { Text: salesOrg.name, TextArrangement: #TextOnly };
  status      @title: '{i18n>Status}';
  grossAmount @title: '{i18n>GrossAmount}'  @Measures.ISOCurrency : currency_code;
  note        @title: '{i18n>Note}'         @UI.MultiLineText;
}

////////////////////////////////////////////////////////////////////////////
//
//  Sales Order Items — element titles
//
annotate my.SalesOrderItems with {
  position  @title: '{i18n>Position}';
  product   @title: '{i18n>Product}'   @Common: { Text: product.name, TextArrangement: #TextOnly };
  quantity  @title: '{i18n>Quantity}';
  unitPrice @title: '{i18n>UnitPrice}' @Measures.ISOCurrency : currency_code;
  netAmount @title: '{i18n>NetAmount}' @Measures.ISOCurrency : currency_code;
}

////////////////////////////////////////////////////////////////////////////
//
//  Customers — list
//
annotate my.Customers with @(
  Common.SemanticKey : [ID],
  UI                 : {
    Identification  : [{ Value: name }],
    SelectionFields : [
      name,
      country,
      segment
    ],
    LineItem        : [
      { Value: ID },
      { Value: name },
      { Value: country },
      { Value: city },
      { Value: segment },
      { Value: customerSince },
    ],
  }
) {
  ID @Common: {
    SemanticObject  : 'Customer',
    Text            : name,
    TextArrangement : #TextOnly,
  };
};

////////////////////////////////////////////////////////////////////////////
//
//  Customers — header info
//
annotate my.Customers with @(UI : {
  HeaderInfo : {
    TypeName       : '{i18n>Customer}',
    TypeNamePlural : '{i18n>Customers}',
    Title          : { Value: name },
    Description    : { Value: country }
  },
  Facets : [{
    $Type  : 'UI.ReferenceFacet',
    Target : 'orders/@UI.LineItem'
  }, ],
});

////////////////////////////////////////////////////////////////////////////
//
//  Customers — element titles
//
annotate my.Customers with {
  ID            @title: '{i18n>ID}';
  name          @title: '{i18n>Name}';
  country       @title: '{i18n>Country}';
  city          @title: '{i18n>City}';
  email         @title: '{i18n>Email}';
  customerSince @title: '{i18n>CustomerSince}';
  segment       @title: '{i18n>Segment}';
}

////////////////////////////////////////////////////////////////////////////
//
//  Products — element titles
//
annotate my.Products with {
  ID          @title: '{i18n>ID}';
  name        @title: '{i18n>ProductName}';
  description @title: '{i18n>Description}'  @UI.MultiLineText;
  category    @title: '{i18n>Category}'     @Common: { Text: category.name, TextArrangement: #TextOnly };
  price       @title: '{i18n>Price}'        @Measures.ISOCurrency : currency_code;
  stock       @title: '{i18n>Stock}';
  supplier    @title: '{i18n>Supplier}';
}

////////////////////////////////////////////////////////////////////////////
//
//  Currencies — common annotations
//
annotate common.Currencies with {
  symbol @Common.Label : '{i18n>Currency}';
}

annotate common.Currencies with @(
  Common.SemanticKey : [code],
  Identification     : [{ Value: code }],
  UI                 : {
    SelectionFields : [
      name,
      descr
    ],
    LineItem        : [
      { Value: descr },
      { Value: symbol },
      { Value: code },
    ],
  }
);

annotate common.Currencies with @(UI : {
  HeaderInfo           : {
    TypeName       : '{i18n>Currency}',
    TypeNamePlural : '{i18n>Currencies}',
    Title          : { Value: descr },
    Description    : { Value: code }
  },
  Facets               : [
    {
      $Type  : 'UI.ReferenceFacet',
      Label  : '{i18n>Details}',
      Target : '@UI.FieldGroup#Details'
    },
    {
      $Type  : 'UI.ReferenceFacet',
      Label  : '{i18n>Extended}',
      Target : '@UI.FieldGroup#Extended'
    },
  ],
  FieldGroup #Details  : {Data : [
    { Value: name },
    { Value: symbol },
    { Value: code },
    { Value: descr }
  ]},
  FieldGroup #Extended : {Data : [
    { Value: numcode },
    { Value: minor },
    { Value: exponent }
  ]},
});

annotate sap.common.Currencies with {
  numcode  @title: '{i18n>NumCode}';
  minor    @title: '{i18n>MinorUnit}';
  exponent @title: '{i18n>Exponent}';
}
