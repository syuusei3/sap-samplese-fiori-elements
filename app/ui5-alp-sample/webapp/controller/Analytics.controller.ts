import BaseController from "./BaseController";
import ODataModel from "sap/ui/model/odata/v4/ODataModel";
import ODataListBinding from "sap/ui/model/odata/v4/ODataListBinding";
import Context from "sap/ui/model/odata/v4/Context";
import JSONModel from "sap/ui/model/json/JSONModel";
import Filter from "sap/ui/model/Filter";
import FilterOperator from "sap/ui/model/FilterOperator";
import Table from "sap/m/Table";
import ListBinding from "sap/ui/model/ListBinding";
import { ListBase$ItemPressEvent } from "sap/m/ListBase";
import { ComboBox$SelectionChangeEvent } from "sap/m/ComboBox";
import { Select$ChangeEvent } from "sap/m/Select";

/**
 * Analytics List Page (Freestyle implementation):
 *  - Header: 3 KPI ObjectNumbers (total gross / avg gross / order count)
 *  - VizFrame chart with switchable Column / Bar / Donut
 *  - Filter on status & customer
 *  - Linked Table that drills to ObjectPage on row click
 *
 * @namespace ui5alpsample.controller
 */
export default class Analytics extends BaseController {

	private statusFilter: string | null = null;
	private customerFilter: string | null = null;
	private chartType: "column" | "bar" | "donut" = "column";

	public async onInit(): Promise<void> {
		const view = this.getView();
		view.setModel(new JSONModel({
			kpi: { totalGross: 0, avgGross: 0, orderCount: 0, currency: "" },
			chart: { rows: [] as Array<{ dim: string; value: number }> },
			chartType: "column"
		}), "alp");

		await this.refreshKpis();
		await this.refreshChart();
	}

	public async onStatusChange(event: ComboBox$SelectionChangeEvent): Promise<void> {
		this.statusFilter = event.getSource().getSelectedKey() || null;
		await this.refreshAll();
	}

	public async onCustomerChange(event: ComboBox$SelectionChangeEvent): Promise<void> {
		this.customerFilter = event.getSource().getSelectedKey() || null;
		await this.refreshAll();
	}

	public async onChartTypeChange(event: Select$ChangeEvent): Promise<void> {
		const key = event.getSource().getSelectedKey() as "column" | "bar" | "donut";
		this.chartType = key;
		(this.getView().getModel("alp") as JSONModel).setProperty("/chartType", key);
		await this.refreshChart();
	}

	public async onGo(): Promise<void> {
		await this.refreshAll();
	}

	private async refreshAll(): Promise<void> {
		await Promise.all([this.refreshKpis(), this.refreshChart(), this.applyTableFilter()]);
	}

	private buildFilters(): Filter[] {
		const filters: Filter[] = [];
		if (this.statusFilter) filters.push(new Filter("status", FilterOperator.EQ, this.statusFilter));
		if (this.customerFilter) filters.push(new Filter("customer_ID", FilterOperator.EQ, this.customerFilter));
		return filters;
	}

	private async refreshKpis(): Promise<void> {
		const model = this.getOwnerComponent().getModel() as ODataModel;
		const filters = this.buildFilters();
		const binding = model.bindList("/ListOfOrders", undefined, undefined, filters, {
			$select: "ID,grossAmount,currency_code,statusCriticality"
		}) as ODataListBinding;
		try {
			const ctxs = await binding.requestContexts(0, 1000) as Context[];
			let total = 0;
			let count = 0;
			let currency = "";
			for (const c of ctxs) {
				const g = c.getProperty("grossAmount") as number;
				if (typeof g === "number") {
					total += g;
					count++;
				}
				if (!currency) currency = c.getProperty("currency_code") as string || "";
			}
			const avg = count > 0 ? total / count : 0;
			(this.getView().getModel("alp") as JSONModel).setProperty("/kpi", {
				totalGross: total,
				avgGross: avg,
				orderCount: count,
				currency
			});
		} catch (e) {
			// keep defaults on failure
		}
	}

	private async refreshChart(): Promise<void> {
		const model = this.getOwnerComponent().getModel() as ODataModel;
		const filters = this.buildFilters();
		const binding = model.bindList("/ListOfOrders", undefined, undefined, filters, {
			$select: "status,grossAmount,customerName,customerCountry"
		}) as ODataListBinding;
		try {
			const ctxs = await binding.requestContexts(0, 1000) as Context[];
			const groupBy = this.chartType === "donut" ? "customerCountry" : "status";
			const buckets: Record<string, number> = {};
			for (const c of ctxs) {
				const dim = c.getProperty(groupBy) as string || "(unknown)";
				const g = c.getProperty("grossAmount") as number || 0;
				buckets[dim] = (buckets[dim] || 0) + g;
			}
			const rows = Object.entries(buckets).map(([dim, value]) => ({ dim, value }));
			(this.getView().getModel("alp") as JSONModel).setProperty("/chart/rows", rows);
		} catch (e) {
			(this.getView().getModel("alp") as JSONModel).setProperty("/chart/rows", []);
		}
	}

	private applyTableFilter(): Promise<void> {
		const table = this.byId("ordersTable") as Table;
		const binding = table.getBinding("items") as ListBinding;
		if (binding) binding.filter(this.buildFilters());
		return Promise.resolve();
	}

	public onItemPress(event: ListBase$ItemPressEvent): void {
		const item = event.getParameter("listItem");
		const ctx = item.getBindingContext() as Context;
		const orderId = ctx.getProperty("ID") as number;
		this.getRouter().navTo("object", { orderId: encodeURIComponent(String(orderId)) });
	}
}
