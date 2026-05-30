using CatalogServiceObjectpage as service from '../../srv/sample-services';

annotate service.SalesOrders with @(
  UI.HeaderInfo : {
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { Value: orderNo },
    Description    : { Value: customer.name }
  },
  UI.HeaderFacets : [
    { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#GrossAmountDP' },
    { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#StatusDP' }
  ],
  UI.DataPoint #GrossAmountDP : {
    Title : 'Gross Amount',
    Value : grossAmount
  },
  UI.DataPoint #StatusDP : {
    Title : 'Status',
    Value : status
  },
  UI.FieldGroup #General : {
    Data : [
      { $Type: 'UI.DataField', Value: orderNo,       Label: 'Order No.' },
      { $Type: 'UI.DataField', Value: orderDate,     Label: 'Order Date' },
      { $Type: 'UI.DataField', Value: customer.name, Label: 'Customer' },
      { $Type: 'UI.DataField', Value: salesOrg.name, Label: 'Sales Org' },
      { $Type: 'UI.DataField', Value: status,        Label: 'Status' }
    ]
  },
  UI.FieldGroup #Amounts : {
    Data : [
      { $Type: 'UI.DataField', Value: grossAmount,     Label: 'Gross Amount' },
      { $Type: 'UI.DataField', Value: currency.symbol, Label: 'Currency' },
      { $Type: 'UI.DataField', Value: note,            Label: 'Note' }
    ]
  },
  UI.Facets : [
    { $Type: 'UI.ReferenceFacet', ID: 'General', Label: 'General Information', Target: '@UI.FieldGroup#General' },
    { $Type: 'UI.ReferenceFacet', ID: 'Amounts', Label: 'Amounts',             Target: '@UI.FieldGroup#Amounts' }
  ]
);
