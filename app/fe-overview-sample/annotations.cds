using CatalogServiceOverview as service from '../../srv/sample-services';

// ==========================================================================
// Sales Orders - LineItem & metadata for List / Stack / QuickView cards
// ==========================================================================
annotate service.ListOfOrders with @(
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: orderNo,       Label: 'Order No.' },
    { $Type: 'UI.DataField', Value: orderDate,     Label: 'Order Date' },
    { $Type: 'UI.DataField', Value: customerName, Label: 'Customer' },
    { $Type: 'UI.DataField', Value: status,        Label: 'Status' },
    { $Type: 'UI.DataField', Value: grossAmount,   Label: 'Gross Amount' }
  ],
  UI.HeaderInfo : {
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { Value: orderNo },
    Description    : { Value: customerName }
  },
  UI.SelectionFields : [ status, salesOrg_code, customer_ID ],
  UI.Identification : [
    { $Type: 'UI.DataField', Value: orderNo, Label: 'Order No.' }
  ]
);

// Charts (no Aggregation.ApplySupported - cov2ap V2 OVP does in-memory aggregation)
annotate service.ListOfOrders with @(
  UI.Chart #revenueChart : {
    Title              : 'Revenue by Sales Org',
    ChartType          : #Column,
    Dimensions         : [salesOrg_code],
    DimensionAttributes: [{
      Dimension: salesOrg_code,
      Role     : #Category
    }],
    Measures           : [grossAmount],
    MeasureAttributes  : [{
      Measure: grossAmount,
      Role   : #Axis1
    }]
  },
  UI.Chart #ordersByStatus : {
    Title              : 'Orders by Status',
    ChartType          : #Donut,
    Dimensions         : [status],
    DimensionAttributes: [{
      Dimension: status,
      Role     : #Category
    }],
    Measures           : [grossAmount],
    MeasureAttributes  : [{
      Measure: grossAmount,
      Role   : #Axis1
    }]
  },
  UI.PresentationVariant #pvRevenueChart : {
    Visualizations : [ '@UI.Chart#revenueChart' ],
    SortOrder      : [{ Property: grossAmount, Descending: true }]
  },
  UI.PresentationVariant #pvOrdersByStatus : {
    Visualizations : [ '@UI.Chart#ordersByStatus' ],
    SortOrder      : [{ Property: grossAmount, Descending: true }]
  },
  UI.PresentationVariant #pvOpenOrders : {
    Visualizations : [ '@UI.LineItem' ],
    SortOrder      : [{ Property: orderDate, Descending: true }]
  },
  UI.PresentationVariant #pvTopOrders : {
    Visualizations : [ '@UI.LineItem' ],
    SortOrder      : [{ Property: grossAmount, Descending: true }]
  },

  // KPI: Total Open Order Amount
  UI.DataPoint #openOrdersKPI : {
    Title         : 'Open Order Amount',
    Value         : grossAmount,
    CriticalityCalculation : {
      ImprovementDirection  : #Maximize,
      DeviationRangeLowValue: 100000,
      ToleranceRangeLowValue: 50000
    }
  },

  // Quick View FieldGroup
  UI.FieldGroup #ovpQuickView : {
    Label : 'Order Details',
    Data  : [
      { $Type: 'UI.DataField', Value: orderNo,      Label: 'Order No.' },
      { $Type: 'UI.DataField', Value: orderDate,    Label: 'Order Date' },
      { $Type: 'UI.DataField', Value: customerName, Label: 'Customer' },
      { $Type: 'UI.DataField', Value: salesOrgName, Label: 'Sales Org' },
      { $Type: 'UI.DataField', Value: status,       Label: 'Status' },
      { $Type: 'UI.DataField', Value: grossAmount,  Label: 'Gross Amount' }
    ]
  }
);

// ==========================================================================
// Products - LineItem & Stock Donut card
// ==========================================================================
annotate service.Products with @(
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: name,         Label: 'Product' },
    { $Type: 'UI.DataField', Value: categoryName, Label: 'Category' },
    {
      $Type                     : 'UI.DataField',
      Value                     : stock,
      Label                     : 'Stock',
      Criticality               : stockCriticality,
      CriticalityRepresentation : #WithoutIcon
    },
    { $Type: 'UI.DataField', Value: price, Label: 'Price' }
  ],
  UI.HeaderInfo : {
    TypeName       : 'Product',
    TypeNamePlural : 'Products',
    Title          : { Value: name },
    Description    : { Value: categoryName }
  },
  UI.Identification : [
    { $Type: 'UI.DataField', Value: name, Label: 'Product' }
  ]
);

annotate service.Products with @(
  UI.Chart #stockDonut : {
    Title              : 'Stock Distribution by Category',
    ChartType          : #Donut,
    Dimensions         : [category_ID],
    DimensionAttributes: [{
      Dimension: category_ID,
      Role     : #Category
    }],
    Measures           : [stock],
    MeasureAttributes  : [{
      Measure: stock,
      Role   : #Axis1
    }]
  },
  UI.PresentationVariant #pvStockDonut : {
    Visualizations : [ '@UI.Chart#stockDonut' ],
    SortOrder      : [{ Property: stock, Descending: true }]
  },
  UI.PresentationVariant #pvProductList : {
    Visualizations : [ '@UI.LineItem' ],
    SortOrder      : [{ Property: stock, Descending: false }]
  }
);

// ==========================================================================
// Customers - LineItem for Top Customers stack
// ==========================================================================
annotate service.Customers with @(
  UI.LineItem : [
    { $Type: 'UI.DataField', Value: name,    Label: 'Customer' },
    { $Type: 'UI.DataField', Value: country, Label: 'Country' },
    { $Type: 'UI.DataField', Value: segment, Label: 'Segment' }
  ],
  UI.HeaderInfo : {
    TypeName       : 'Customer',
    TypeNamePlural : 'Customers',
    Title          : { Value: name },
    Description    : { Value: country }
  },
  UI.PresentationVariant #pvCustomerList : {
    Visualizations : [ '@UI.LineItem' ],
    SortOrder      : [{ Property: name, Descending: false }]
  },
  UI.Identification : [
    { $Type: 'UI.DataField', Value: name, Label: 'Customer' }
  ]
);
