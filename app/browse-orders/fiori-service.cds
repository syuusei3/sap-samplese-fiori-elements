using CatalogService from '../../srv/cat-service';

////////////////////////////////////////////////////////////////////////////
//
//	Sales Order Object Page
//
annotate CatalogService.SalesOrders with @(UI : {
  HeaderInfo : {
    TypeName       : '{i18n>SalesOrder}',
    TypeNamePlural : '{i18n>SalesOrders}',
    Title          : { Value : orderNo },
    Description    : { Value : customerName }
  },
  HeaderFacets : [{
    $Type  : 'UI.ReferenceFacet',
    Label  : '{i18n>Status}',
    Target : '@UI.FieldGroup#StatusGroup'
  }, ],
  Facets       : [{
    $Type  : 'UI.ReferenceFacet',
    Label  : '{i18n>Details}',
    Target : '@UI.FieldGroup#Amount'
  }, ],
  FieldGroup #StatusGroup : {Data : [{Value : status}]},
  FieldGroup #Amount      : {Data : [
    { Value : grossAmount },
    {
      Value : currency.symbol,
      Label : '{i18n>Currency}'
    },
  ]},
});


////////////////////////////////////////////////////////////////////////////
//
//	Sales Order List Page
//
annotate CatalogService.SalesOrders with @(UI : {
  SelectionFields : [
    orderNo,
    orderDate,
    status,
    customer_ID
  ],
  LineItem        : [
    { Value: orderNo,       Label: '{i18n>OrderNo}' },
    { Value: orderDate,     Label: '{i18n>OrderDate}' },
    { Value: customerName,  Label: '{i18n>Customer}' },
    { Value: status,        Label: '{i18n>Status}' },
    { Value: grossAmount,   Label: '{i18n>GrossAmount}' },
    { Value: currency.symbol, Label: '{i18n>Currency}' },
  ]
});
