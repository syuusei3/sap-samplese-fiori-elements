using CatalogService as service from '../../srv/cat-service';

annotate service.ListOfOrders with @(
  UI.HeaderInfo : {
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { Value: orderNo },
    Description    : { Value: customer.name }
  },
  UI.SelectionFields : [ orderNo, customer_ID, salesOrg_code, status ],
  UI.PresentationVariant : {
    SortOrder : [ { Property: orderDate, Descending: true } ],
    Visualizations : [ '@UI.LineItem' ]
  },
  UI.SelectionPresentationVariant #Open : {
    Text : 'Open Orders',
    SelectionVariant : {
      Text       : 'Open Orders',
      SelectOptions : [
        {
          PropertyName : status,
          Ranges : [
            { Sign: #I, Option: #EQ, Low: 'New' },
            { Sign: #I, Option: #EQ, Low: 'InProgress' }
          ]
        }
      ]
    },
    PresentationVariant : {
      SortOrder : [ { Property: orderDate, Descending: true } ],
      Visualizations : [ '@UI.LineItem' ]
    }
  },
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
  UI.Facets : [
    { $Type: 'UI.ReferenceFacet', ID: 'General', Label: 'General Information', Target: '@UI.FieldGroup#General' }
  ]
);
