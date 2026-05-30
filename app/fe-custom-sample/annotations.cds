using CatalogServiceCustom as service from '../../srv/sample-services';

annotate service.SalesOrders with @(
  UI.HeaderInfo : {
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { Value: orderNo },
    Description    : { Value: customer.name }
  },
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: orderNo,       Label: 'Order No.' },
    { $Type: 'UI.DataField', Value: customer.name, Label: 'Customer' },
    { $Type: 'UI.DataField', Value: status,        Label: 'Status' },
    { $Type: 'UI.DataField', Value: grossAmount,   Label: 'Gross Amount' }
  ],
  UI.FieldGroup #General : {
    Data : [
      { $Type: 'UI.DataField', Value: orderNo,       Label: 'Order No.' },
      { $Type: 'UI.DataField', Value: orderDate,     Label: 'Order Date' },
      { $Type: 'UI.DataField', Value: customer.name, Label: 'Customer' },
      { $Type: 'UI.DataField', Value: salesOrg.name, Label: 'Sales Org' },
      { $Type: 'UI.DataField', Value: status,        Label: 'Status' },
      { $Type: 'UI.DataField', Value: grossAmount,   Label: 'Gross Amount' }
    ]
  },
  UI.Facets : [
    { $Type: 'UI.ReferenceFacet', ID: 'General', Label: 'General Information', Target: '@UI.FieldGroup#General' }
  ]
);
