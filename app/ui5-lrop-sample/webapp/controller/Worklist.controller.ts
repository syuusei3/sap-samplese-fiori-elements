import BaseController from "./BaseController";
import { ListBase$ItemPressEvent } from "sap/m/ListBase";
import Filter from "sap/ui/model/Filter";
import FilterOperator from "sap/ui/model/FilterOperator";
import Table from "sap/m/Table";
import ListBinding from "sap/ui/model/ListBinding";
import Context from "sap/ui/model/odata/v4/Context";
import { SearchField$LiveChangeEvent } from "sap/m/SearchField";
import { ComboBox$SelectionChangeEvent } from "sap/m/ComboBox";

/**
 * Worklist (List Report) controller — Freestyle re-implementation of the
 * Fiori Elements List Report floorplan.
 *
 * @namespace ui5lropsample.controller
 */
export default class Worklist extends BaseController {

	private searchQuery = "";
	private customerId: string | null = null;
	private status: string | null = null;

	public onInit(): void {
		// nothing yet
	}

	public onSearch(event: SearchField$LiveChangeEvent): void {
		this.searchQuery = event.getParameter("newValue") || "";
		this.applyFilters();
	}

	public onFilterChange(event: ComboBox$SelectionChangeEvent): void {
		const source = event.getSource();
		const selectedKey = source.getSelectedKey() || null;
		if (source.getId().endsWith("customerFilter")) {
			this.customerId = selectedKey;
		} else {
			this.status = selectedKey;
		}
		this.applyFilters();
	}

	private applyFilters(): void {
		const filters: Filter[] = [];

		if (this.searchQuery) {
			filters.push(new Filter({
				filters: [
					new Filter("orderNo",       FilterOperator.Contains, this.searchQuery),
					new Filter("customer/name", FilterOperator.Contains, this.searchQuery)
				],
				and: false
			}));
		}
		if (this.customerId) {
			filters.push(new Filter("customer_ID", FilterOperator.EQ, this.customerId));
		}
		if (this.status) {
			filters.push(new Filter("status", FilterOperator.EQ, this.status));
		}

		const table = this.byId("ordersTable") as Table;
		const binding = table.getBinding("items") as ListBinding;
		binding.filter(filters);
	}

	public onItemPress(event: ListBase$ItemPressEvent): void {
		const item = event.getParameter("listItem");
		const ctx = item.getBindingContext() as Context;
		const orderId = ctx.getProperty("ID") as string;
		this.getRouter().navTo("object", { orderId: encodeURIComponent(orderId) });
	}
}
