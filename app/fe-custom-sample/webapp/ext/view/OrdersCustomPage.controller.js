sap.ui.define([
    "sap/fe/core/PageController",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/m/MessageToast"
], function (PageController, Filter, FilterOperator, MessageToast) {
    "use strict";

    return PageController.extend("fecustomsample.ext.view.OrdersCustomPage", {

        onInit: function () {
            PageController.prototype.onInit.apply(this, arguments);
        },

        onSearch: function (oEvent) {
            var sQuery = oEvent.getParameter("query") || oEvent.getParameter("newValue") || "";
            var oTable = this.byId("ordersTable");
            var oBinding = oTable.getBinding("items");
            if (!oBinding) { return; }
            if (sQuery) {
                oBinding.filter(new Filter({
                    filters: [
                        new Filter("orderNo",       FilterOperator.Contains, sQuery),
                        new Filter("customer/name", FilterOperator.Contains, sQuery)
                    ],
                    and: false
                }));
            } else {
                oBinding.filter([]);
            }
        },

        onRefresh: function () {
            var oBinding = this.byId("ordersTable").getBinding("items");
            if (oBinding) {
                oBinding.refresh();
                MessageToast.show("Refreshed");
            }
        },

        onItemPress: function (oEvent) {
            var oCtx = oEvent.getSource().getBindingContext();
            if (!oCtx) { return; }
            var oExt = this.getExtensionAPI && this.getExtensionAPI();
            if (oExt && oExt.routing) {
                oExt.routing.navigateToRoute("SalesOrdersObjectPage", {
                    key: "ID=" + oCtx.getProperty("ID")
                });
            }
        },

        formatAmount: function (v) {
            if (v === null || v === undefined) { return ""; }
            return Number(v).toFixed(2);
        }
    });
});
