using {
  Currency,
  cuid,
  managed,
  sap
} from '@sap/cds/common';

namespace sap.capire.salesorders;

/**
 * Sales order header — draft-enabled root entity for the order management UI.
 */
entity SalesOrders : managed {
  key ID          : Integer;
      orderNo     : String(20)                    @mandatory;
      orderDate   : Date                          @mandatory;
      customer    : Association to Customers      @mandatory;
      salesOrg    : Association to SalesOrgs      @mandatory;
      status      : String @mandatory enum {
                      New;
                      InProgress;
                      Shipped;
                      Completed;
                      Cancelled;
                    };
      grossAmount : Decimal(15, 2);
      currency    : Currency;
      note        : String(1000);
      items       : Composition of many SalesOrderItems
                      on items.parent = $self;
}

/**
 * Sales order item — child of SalesOrders.
 */
entity SalesOrderItems : cuid, managed {
  parent    : Association to SalesOrders;
  position  : Integer                       @mandatory;
  product   : Association to Products       @mandatory;
  quantity  : Integer                       @mandatory;
  unitPrice : Decimal(13, 2);
  netAmount : Decimal(15, 2);
  currency  : Currency;
}

/**
 * Customers / business partners.
 */
entity Customers : managed {
  key ID            : Integer;
      name          : String(120)                 @mandatory;
      country       : String(3); // ISO 3166-1 alpha-2/3
      city          : String(80);
      email         : String(120);
      customerSince : Date;
      segment       : String enum {
                        Strategic;
                        Enterprise;
                        Mid;
                        Small;
                      };
      orders        : Association to many SalesOrders
                        on orders.customer = $self;
}

/**
 * Products that can be sold.
 */
entity Products : managed {
  key ID          : Integer;
      name        : localized String(120)         @mandatory;
      description : localized String(2000);
      category    : Association to ProductCategories;
      price       : Decimal(13, 2);
      currency    : Currency;
      stock       : Integer;
      supplier    : String(120);
}

/** Hierarchically organized code list for product categories (e.g. Hardware > Sensors). */
entity ProductCategories : cuid, sap.common.CodeList {
  parent   : Association to ProductCategories;
  children : Composition of many ProductCategories
               on children.parent = $self;
}

/** Sales organization code list (e.g. JP01, US01). */
entity SalesOrgs : sap.common.CodeList {
  key code    : String(10);
      country : String(3);
}


// --------------------------------------------------------------------------------
// Draft enablement for the SalesOrders root.
// SalesOrderItems is reached via composition and inherits draft handling.
annotate SalesOrders with @fiori.draft.enabled;
