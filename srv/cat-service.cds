using {sap.capire.salesorders as my} from '../db/schema';

service CatalogService {

  /** For displaying lists of orders (read-only, denormalized). */
  @readonly
  entity ListOfOrders as
    projection on SalesOrders {
      *,
      customer.name   as customerName : String,
      salesOrg.name   as salesOrgName : String,
      currency.symbol as currencySymbol : String,
    }
    excluding {
      note
    };

  /** For display in detail pages. */
  @readonly
  entity SalesOrders  as
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
  entity Products     as
    projection on my.Products {
      *,
      category.name as categoryName : String
    }
    excluding {
      createdBy,
      modifiedBy
    };

  /** Submit (confirm) an existing sales order: New → InProgress and reduce stock. */
  @requires: 'authenticated-user'
  action submitOrder(orderID: SalesOrders:ID) returns {
    status : String;
  };
}
