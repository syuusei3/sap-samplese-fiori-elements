import BaseController from "./BaseController";
import ODataModel from "sap/ui/model/odata/v4/ODataModel";
import ODataListBinding from "sap/ui/model/odata/v4/ODataListBinding";
import Context from "sap/ui/model/odata/v4/Context";
import JSONModel from "sap/ui/model/json/JSONModel";
import { ListBase$ItemPressEvent } from "sap/m/ListBase";

/**
 * Overview dashboard controller. Aggregates client-side (small dataset) and feeds
 * a JsonModel that drives 6 sap.f.Cards.
 *
 * @namespace ui5overviewsample.controller
 */
export default class Overview extends BaseController {

	public async onInit(): Promise<void> {
		const view = this.getView();
		view.setModel(new JSONModel({
			topOrders: [] as Array<{ ID: number; orderNo: string; customerName: string; grossAmount: number; currency_code: string; status: string }>,
			byStatus: [] as Array<{ dim: string; value: number }>,
			byCountry: [] as Array<{ dim: string; value: number }>,
			kpi: { totalGross: 0, currency: "" },
			lowStockProducts: [] as Array<{ ID: number; name: string; stock: number; stockCriticality: number }>,
			selected: { orderNo: "(none)", customerName: "—", grossAmount: 0, status: "—", currency: "" }
		}), "ovp");

		await Promise.all([this.loadOrders(), this.loadProducts()]);
	}

	private async loadOrders(): Promise<void> {
		const model = this.getOwnerComponent().getModel() as ODataModel;
		const binding = model.bindList("/ListOfOrders", undefined, undefined, undefined, {
			$select: "ID,orderNo,customerName,customerCountry,salesOrgName,status,grossAmount,currency_code"
		}) as ODataListBinding;
		try {
			const ctxs = await binding.requestContexts(0, 500) as Context[];
			const all = ctxs.map(c => ({
				ID: c.getProperty("ID") as number,
				orderNo: c.getProperty("orderNo") as string,
				customerName: c.getProperty("customerName") as string,
				customerCountry: c.getProperty("customerCountry") as string || "(unknown)",
				status: c.getProperty("status") as string,
				grossAmount: c.getProperty("grossAmount") as number || 0,
				currency_code: c.getProperty("currency_code") as string
			}));

			const top = [...all].sort((a, b) => b.grossAmount - a.grossAmount).slice(0, 5);

			const byStatus: Record<string, number> = {};
			const byCountry: Record<string, number> = {};
			let total = 0;
			let currency = "";
			for (const o of all) {
				byStatus[o.status] = (byStatus[o.status] || 0) + o.grossAmount;
				byCountry[o.customerCountry] = (byCountry[o.customerCountry] || 0) + o.grossAmount;
				total += o.grossAmount;
				if (!currency) currency = o.currency_code;
			}

			const ovp = this.getView().getModel("ovp") as JSONModel;
			ovp.setProperty("/topOrders", top);
			ovp.setProperty("/byStatus", Object.entries(byStatus).map(([dim, value]) => ({ dim, value })));
			ovp.setProperty("/byCountry", Object.entries(byCountry).map(([dim, value]) => ({ dim, value })));
			ovp.setProperty("/kpi", { totalGross: total, currency });
		} catch (e) {
			// keep defaults
		}
	}

	private async loadProducts(): Promise<void> {
		const model = this.getOwnerComponent().getModel() as ODataModel;
		const binding = model.bindList("/Products", undefined, undefined, undefined, {
			$select: "ID,name,stock,stockCriticality",
			$orderby: "stock asc",
			$top: 5
		}) as ODataListBinding;
		try {
			const ctxs = await binding.requestContexts(0, 5) as Context[];
			const products = ctxs.map(c => ({
				ID: c.getProperty("ID") as number,
				name: c.getProperty("name") as string,
				stock: c.getProperty("stock") as number,
				stockCriticality: c.getProperty("stockCriticality") as number
			}));
			(this.getView().getModel("ovp") as JSONModel).setProperty("/lowStockProducts", products);
		} catch (e) {
			// keep defaults
		}
	}

	public onTopOrderPress(event: ListBase$ItemPressEvent): void {
		const item = event.getParameter("listItem");
		const ctx = item.getBindingContext("ovp");
		if (!ctx) return;
		const o = ctx.getObject() as { orderNo: string; customerName: string; grossAmount: number; status: string; currency_code: string };
		(this.getView().getModel("ovp") as JSONModel).setProperty("/selected", {
			orderNo: o.orderNo,
			customerName: o.customerName,
			grossAmount: o.grossAmount,
			status: o.status,
			currency: o.currency_code
		});
	}

	public onTopOrderNav(event: ListBase$ItemPressEvent): void {
		const item = event.getParameter("listItem");
		const ctx = item.getBindingContext("ovp");
		if (!ctx) return;
		const id = (ctx.getObject() as { ID: number }).ID;
		this.getRouter().navTo("object", { orderId: encodeURIComponent(String(id)) });
	}
}
