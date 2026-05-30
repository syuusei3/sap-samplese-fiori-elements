using CatalogServiceLrop as service from '../../srv/sample-services';

annotate service.SalesOrders with @(
  UI.HeaderInfo : {
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { Value: orderNo },
    Description    : { Value: customer.name }
  },
  UI.SelectionFields : [ orderNo, customer_ID, salesOrg_code, status, orderDate ],
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: orderNo,         Label: 'Order No.' },
    { $Type: 'UI.DataField', Value: orderDate,       Label: 'Order Date' },
    { $Type: 'UI.DataField', Value: customer.name,   Label: 'Customer' },
    { $Type: 'UI.DataField', Value: salesOrg.name,   Label: 'Sales Org' },
    { $Type: 'UI.DataField', Value: status,          Label: 'Status' },
    { $Type: 'UI.DataField', Value: grossAmount,     Label: 'Gross Amount' },
    { $Type: 'UI.DataField', Value: currency.symbol, Label: 'Currency' }
  ],
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
    { $Type: 'UI.ReferenceFacet', ID: 'Amounts', Label: 'Amounts',             Target: '@UI.FieldGroup#Amounts' },
    { $Type: 'UI.ReferenceFacet', ID: 'Items',   Label: 'Order Items',         Target: 'items/@UI.LineItem' }
  ]
);

annotate service.SalesOrderItems with @(
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: position,        Label: 'Position' },
    { $Type: 'UI.DataField', Value: product.name,    Label: 'Product' },
    { $Type: 'UI.DataField', Value: quantity,        Label: 'Quantity' },
    { $Type: 'UI.DataField', Value: unitPrice,       Label: 'Unit Price' },
    { $Type: 'UI.DataField', Value: netAmount,       Label: 'Net Amount' },
    { $Type: 'UI.DataField', Value: currency.symbol, Label: 'Currency' }
  ]
);
