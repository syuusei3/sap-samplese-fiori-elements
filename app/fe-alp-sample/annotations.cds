using CatalogServiceAlp as service from '../../srv/sample-services';

// Override Text annotations so chart dimensions don't try to resolve text via
// association ($expand is not supported in $apply queries). Annotating the
// association makes CAP propagate the override to the foreign-key element
// (customer_ID / salesOrg_code / etc.) in OData metadata.
annotate service.ListOfOrders with {
  customer @Common.Text : customerName @Common.TextArrangement : #TextOnly;
  salesOrg @Common.Text : salesOrgName @Common.TextArrangement : #TextOnly;
};

// ---- Analytical: AggregatedProperty (4 measures) + ApplySupported ----
annotate service.ListOfOrders with @(
  Analytics.AggregatedProperty #totalGross : {
    Name                : 'totalGross',
    AggregationMethod   : 'sum',
    AggregatableProperty: 'grossAmount',
    ![@Common.Label]    : 'Total Gross Amount'
  },
  Analytics.AggregatedProperty #avgGross : {
    Name                : 'avgGross',
    AggregationMethod   : 'average',
    AggregatableProperty: 'grossAmount',
    ![@Common.Label]    : 'Avg Gross Amount'
  },
  Analytics.AggregatedProperty #ordersCount : {
    Name                : 'ordersCount',
    AggregationMethod   : 'countdistinct',
    AggregatableProperty: 'ID',
    ![@Common.Label]    : 'Orders Count'
  },
  Aggregation.ApplySupported : {
    Transformations          : ['aggregate', 'topcount', 'bottomcount', 'identity', 'concat', 'groupby', 'filter', 'top', 'skip', 'orderby', 'search'],
    Rollup                   : #None,
    PropertyRestrictions     : true,
    GroupableProperties      : [customer_ID, salesOrg_code, currency_code, status, customerCountry, customerSegment],
    AggregatableProperties   : [
      { Property: grossAmount },
      { Property: ID }
    ]
  }
);

// ---- Header KPIs (UI.DataPoint) ----
annotate service.ListOfOrders with @(
  UI.DataPoint #totalGrossKPI : {
    Value                     : grossAmount,
    Title                     : 'Total Gross Amount',
    Visualization             : #Number
  },
  UI.DataPoint #avgGrossKPI : {
    Value         : grossAmount,
    Title         : 'Avg Gross Amount',
    Visualization : #Number
  },
  UI.DataPoint #ordersCountKPI : {
    Value         : ID,
    Title         : 'Orders',
    Visualization : #Number
  }
);

// ---- Charts (3 different chart types) ----
annotate service.ListOfOrders with @(
  UI.Chart #ordersByCustomer : {
    Title              : 'Total Gross by Customer',
    ChartType          : #Column,
    Dimensions         : [customer_ID],
    DimensionAttributes: [{
      Dimension: customer_ID,
      Role     : #Category
    }],
    DynamicMeasures    : ['@Analytics.AggregatedProperty#totalGross'],
    MeasureAttributes  : [{
      DynamicMeasure: '@Analytics.AggregatedProperty#totalGross',
      Role          : #Axis1
    }]
  },
  UI.Chart #ordersBySalesOrg : {
    Title              : 'Total Gross by Sales Org',
    ChartType          : #Bar,
    Dimensions         : [salesOrg_code],
    DimensionAttributes: [{
      Dimension: salesOrg_code,
      Role     : #Category
    }],
    DynamicMeasures    : ['@Analytics.AggregatedProperty#totalGross'],
    MeasureAttributes  : [{
      DynamicMeasure: '@Analytics.AggregatedProperty#totalGross',
      Role          : #Axis1
    }]
  },
  UI.Chart #ordersByCurrency : {
    Title              : 'Orders by Currency',
    ChartType          : #Donut,
    Dimensions         : [currency_code],
    DimensionAttributes: [{
      Dimension: currency_code,
      Role     : #Category
    }],
    DynamicMeasures    : ['@Analytics.AggregatedProperty#ordersCount'],
    MeasureAttributes  : [{
      DynamicMeasure: '@Analytics.AggregatedProperty#ordersCount',
      Role          : #Axis1
    }]
  }
);

// ---- LineItem override with Criticality on status ----
annotate service.ListOfOrders with @(
  UI.LineItem : [
    { Value: orderNo,         Label: '{i18n>OrderNo}' },
    { Value: orderDate,       Label: '{i18n>OrderDate}' },
    { Value: customerName,    Label: '{i18n>Customer}' },
    { Value: salesOrgName,    Label: '{i18n>SalesOrg}' },
    {
      $Type                     : 'UI.DataField',
      Value                     : status,
      Label                     : '{i18n>Status}',
      Criticality               : statusCriticality,
      CriticalityRepresentation : #WithoutIcon
    },
    { Value: grossAmount,     Label: '{i18n>GrossAmount}' },
    { Value: currency.symbol, Label: '{i18n>Currency}' }
  ]
);

// ---- Presentation / SelectionPresentation Variants ----
annotate service.ListOfOrders with @(
  UI.PresentationVariant #pvByCustomer : {
    Visualizations : [
      '@UI.Chart#ordersByCustomer',
      '@UI.Chart#ordersBySalesOrg',
      '@UI.Chart#ordersByCurrency',
      '@UI.LineItem'
    ],
    SortOrder      : [{
      Property  : grossAmount,
      Descending: true
    }]
  },
  UI.SelectionPresentationVariant #spvByCustomer : {
    Text               : 'Sales Order Analytics',
    PresentationVariant: ![@UI.PresentationVariant#pvByCustomer],
    SelectionVariant   : { SelectOptions: [] }
  }
);

// ---- Header layout: KPIs on top of the ALP page ----
annotate service.ListOfOrders with @(
  UI.HeaderInfo : {
    TypeName      : 'Sales Order',
    TypeNamePlural: 'Sales Orders',
    Title         : { Value: 'Sales Order Analytics' }
  },
  UI.HeaderFacets : [
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.DataPoint#totalGrossKPI',
      Label : 'Total Gross Amount'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.DataPoint#avgGrossKPI',
      Label : 'Avg Gross Amount'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Target: '@UI.DataPoint#ordersCountKPI',
      Label : 'Orders'
    }
  ]
);
