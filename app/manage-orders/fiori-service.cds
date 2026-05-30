using { AdminService } from '../../srv/admin-service';
using from '../common'; // to help UI linter get the complete annotations

////////////////////////////////////////////////////////////////////////////
//
//	Sales Order Items — line item used inside the order's facet
//
annotate AdminService.SalesOrderItems with @(
  UI : {
    LineItem : [
      { Value: position,    Label: '{i18n>Position}' },
      { Value: product_ID,  Label: '{i18n>Product}' },
      { Value: quantity,    Label: '{i18n>Quantity}' },
      { Value: unitPrice,   Label: '{i18n>UnitPrice}' },
      { Value: netAmount,   Label: '{i18n>NetAmount}' },
    ]
  }
);

////////////////////////////////////////////////////////////////////////////
//
//	Sales Order Object Page
//
annotate AdminService.SalesOrders with @(
  UI: {
    Facets: [
      {$Type: 'UI.ReferenceFacet', Label: '{i18n>General}', Target: '@UI.FieldGroup#General'},
      {$Type: 'UI.ReferenceFacet', Label: '{i18n>Items}',   Target: 'items/@UI.LineItem'},
      {$Type: 'UI.ReferenceFacet', Label: '{i18n>Details}', Target: '@UI.FieldGroup#Details'},
      {$Type: 'UI.ReferenceFacet', Label: '{i18n>Admin}',   Target: '@UI.FieldGroup#Admin'},
    ],
    FieldGroup#General: {
      Data: [
        {Value: orderNo},
        {Value: orderDate},
        {Value: customer_ID},
        {Value: salesOrg_code},
        {Value: status},
      ]
    },
    FieldGroup#Details: {
      Data: [
        {Value: grossAmount},
        {Value: currency_code},
        {Value: note},
      ]
    },
    FieldGroup#Admin: {
      Data: [
        {Value: createdBy},
        {Value: createdAt},
        {Value: modifiedBy},
        {Value: modifiedAt}
      ]
    }
  }
);

////////////////////////////////////////////////////////////////////////////
//
//	Value Help for Customer / SalesOrg
//
annotate AdminService.SalesOrders with {
  customer @(Common: {
    Label    : '{i18n>Customer}',
    ValueList: {
      CollectionPath: 'Customers',
      Parameters    : [
        { $Type: 'Common.ValueListParameterInOut',      LocalDataProperty: customer_ID, ValueListProperty: 'ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'country' },
      ],
    }
  });
  salesOrg @(Common: {
    Label    : '{i18n>SalesOrg}',
    ValueList: {
      CollectionPath: 'SalesOrgs',
      Parameters    : [
        { $Type: 'Common.ValueListParameterInOut',      LocalDataProperty: salesOrg_code, ValueListProperty: 'code' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
      ],
    }
  });
};

////////////////////////////////////////////////////////////
//
//  Draft for Sales Orders
//
annotate AdminService.SalesOrders with @odata.draft.enabled;

// ID is auto-generated server-side; hide on Create dialog.
annotate AdminService.SalesOrders with { ID @Core.Computed; }
