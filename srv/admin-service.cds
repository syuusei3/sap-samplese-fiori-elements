using {sap.capire.salesorders as my} from '../db/schema';

service AdminService {
  entity SalesOrders       as projection on my.SalesOrders;
  entity SalesOrderItems   as projection on my.SalesOrderItems;
  entity Customers         as projection on my.Customers;
  entity Products          as projection on my.Products;
  entity ProductCategories as projection on my.ProductCategories;
  entity SalesOrgs         as projection on my.SalesOrgs;
}
