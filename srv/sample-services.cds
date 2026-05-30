using {sap.capire.salesorders as my} from '../db/schema';

// Used by app/fe-lrop-sample
service CatalogServiceLrop @(path: '/odata/v4/catalog-lrop') {
  @readonly
  entity SalesOrders as
    projection on my.SalesOrders {
      *,
      customer.name as customerName : String,
      salesOrg.name as salesOrgName : String,
    }
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity SalesOrderItems as
    projection on my.SalesOrderItems
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity Customers as
    projection on my.Customers
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity Products as
    projection on my.Products {
      *,
      category.name as categoryName : String
    }
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity ProductCategories as projection on my.ProductCategories;

  @readonly
  entity SalesOrgs as projection on my.SalesOrgs;
}

// Used by app/fe-objectpage-sample
service CatalogServiceObjectpage @(path: '/odata/v4/catalog-objectpage') {
  @readonly
  entity SalesOrders as
    projection on my.SalesOrders {
      *,
      customer.name as customerName : String,
      salesOrg.name as salesOrgName : String,
    }
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity SalesOrderItems as
    projection on my.SalesOrderItems
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity Customers as projection on my.Customers excluding { createdBy, modifiedBy };

  @readonly
  entity Products  as projection on my.Products  excluding { createdBy, modifiedBy };
}

// Used by app/fe-custom-sample
service CatalogServiceCustom @(path: '/odata/v4/catalog-custom') {
  @readonly
  entity SalesOrders as
    projection on my.SalesOrders {
      *,
      customer.name as customerName : String,
      salesOrg.name as salesOrgName : String,
    }
    excluding {
      createdBy,
      modifiedBy
    };

  @readonly
  entity SalesOrderItems as projection on my.SalesOrderItems excluding { createdBy, modifiedBy };

  @readonly
  entity Customers as projection on my.Customers excluding { createdBy, modifiedBy };

  @readonly
  entity Products  as projection on my.Products  excluding { createdBy, modifiedBy };
}

// Used by app/fe-alp-sample — analytical view of orders with criticality and aggregations.
service CatalogServiceAlp @(path: '/odata/v4/catalog-alp') {
  @readonly
  entity ListOfOrders as
    projection on my.SalesOrders {
      *,
      customer.name        as customerName : String,
      customer.country     as customerCountry : String,
      customer.segment     as customerSegment : String,
      salesOrg.name        as salesOrgName : String,
      case
        when status = 'Cancelled' then 1   // Negative (red)
        when status = 'New'        then 2  // Critical (yellow)
        when status = 'InProgress' then 2
        else                            3  // Positive (green)
      end as statusCriticality : Integer
    }
    excluding {
      note,
      createdBy,
      modifiedBy
    };
}

// Used by app/fe-overview-sample
// OVP requires OData V2; @cap-js-community/odata-v2-adapter exposes a V2
// endpoint at /odata/v2/catalog-overview alongside the V4 one.
service CatalogServiceOverview @(path: '/odata/v4/catalog-overview') {
  @readonly
  entity ListOfOrders as
    projection on my.SalesOrders {
      *,
      customer.name        as customerName : String,
      customer.country     as customerCountry : String,
      salesOrg.name        as salesOrgName : String,
    }
    excluding {
      note,
      createdBy,
      modifiedBy
    };

  @readonly
  entity Products as
    projection on my.Products {
      *,
      category.name as categoryName : String,
      case
        when stock < 10 then 1
        when stock < 50 then 2
        else                 3
      end as stockCriticality : Integer
    }
    excluding {
      description,
      createdBy,
      modifiedBy
    };

  @readonly
  entity Customers as projection on my.Customers excluding { createdBy, modifiedBy };
}
