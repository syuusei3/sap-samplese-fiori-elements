import BaseController from "./BaseController";
import Filter from "sap/ui/model/Filter";
import FilterOperator from "sap/ui/model/FilterOperator";
import Table from "sap/m/Table";
import ListBinding from "sap/ui/model/ListBinding";
import Context from "sap/ui/model/odata/v4/Context";
import { ListBase$ItemPressEvent } from "sap/m/ListBase";
import { MultiComboBox$SelectionChangeEvent } from "sap/m/MultiComboBox";
import { RangeSlider$ChangeEvent } from "sap/m/RangeSlider";
import { Switch$ChangeEvent } from "sap/m/Switch";
import { SearchField$LiveChangeEvent } from "sap/m/SearchField";
import MultiComboBox from "sap/m/MultiComboBox";
import RangeSlider from "sap/m/RangeSlider";
import Switch from "sap/m/Switch";
import JSONModel from "sap/ui/model/json/JSONModel";
import Token from "sap/m/Token";
import { Tokenizer$TokenDeleteEvent } from "sap/m/Tokenizer";

/**
 * Worklist with custom filters: MultiComboBox (status, customer), RangeSlider (grossAmount),
 * Switch (open orders only), Tokenizer (active filter chips).
 *
 * @namespace ui5customsample.controller
 */
export default class Worklist extends BaseController {

	private searchQuery = "";
	private statusKeys: string[] = [];
	private customerIds: string[] = [];
	private amountMin = 0;
	private amountMax = 100000;
	private openOnly = false;

	public onInit(): void {
		const view = this.getView();
		const stateModel = new JSONModel({
			tokens: [] as Array<{ key: string; text: string }>
		});
		view.setModel(stateModel, "state");
	}

	public onSearch(event: SearchField$LiveChangeEvent): void {
		this.searchQuery = event.getParameter("newValue") || "";
		this.applyFilters();
	}

	public onStatusChange(event: MultiComboBox$SelectionChangeEvent): void {
		const cb = event.getSource() as MultiComboBox;
		this.statusKeys = cb.getSelectedKeys();
		this.applyFilters();
	}

	public onCustomerChange(event: MultiComboBox$SelectionChangeEvent): void {
		const cb = event.getSource() as MultiComboBox;
		this.customerIds = cb.getSelectedKeys();
		this.applyFilters();
	}

	public onAmountChange(event: RangeSlider$ChangeEvent): void {
		const slider = event.getSource() as RangeSlider;
		this.amountMin = slider.getValue();
		this.amountMax = slider.getValue2();
		this.applyFilters();
	}

	public onOpenSwitch(event: Switch$ChangeEvent): void {
		const sw = event.getSource() as Switch;
		this.openOnly = sw.getState();
		this.applyFilters();
	}

	public onClearFilters(): void {
		this.searchQuery = "";
		this.statusKeys = [];
		this.customerIds = [];
		this.amountMin = 0;
		this.amountMax = 100000;
		this.openOnly = false;

		(this.byId("searchField") as { setValue: (v: string) => void }).setValue("");
		(this.byId("statusFilter") as MultiComboBox).setSelectedKeys([]);
		(this.byId("customerFilter") as MultiComboBox).setSelectedKeys([]);
		const slider = this.byId("amountSlider") as RangeSlider;
		slider.setValue(0);
		slider.setValue2(100000);
		(this.byId("openSwitch") as Switch).setState(false);

		this.applyFilters();
	}

	public onTokenDelete(event: Tokenizer$TokenDeleteEvent): void {
		const tokens = event.getParameter("tokens") as Token[];
		for (const tok of tokens) {
			const key = tok.getKey();
			const [group, value] = key.split(":");
			if (group === "status") {
				this.statusKeys = this.statusKeys.filter(s => s !== value);
				(this.byId("statusFilter") as MultiComboBox).setSelectedKeys(this.statusKeys);
			} else if (group === "customer") {
				this.customerIds = this.customerIds.filter(c => c !== value);
				(this.byId("customerFilter") as MultiComboBox).setSelectedKeys(this.customerIds);
			} else if (group === "search") {
				this.searchQuery = "";
				(this.byId("searchField") as { setValue: (v: string) => void }).setValue("");
			} else if (group === "open") {
				this.openOnly = false;
				(this.byId("openSwitch") as Switch).setState(false);
			} else if (group === "amount") {
				this.amountMin = 0;
				this.amountMax = 100000;
				const slider = this.byId("amountSlider") as RangeSlider;
				slider.setValue(0);
				slider.setValue2(100000);
			}
		}
		this.applyFilters();
	}

	private applyFilters(): void {
		const filters: Filter[] = [];
		const tokens: Array<{ key: string; text: string }> = [];

		if (this.searchQuery) {
			filters.push(new Filter({
				filters: [
					new Filter("orderNo", FilterOperator.Contains, this.searchQuery),
					new Filter("customerName", FilterOperator.Contains, this.searchQuery)
				],
				and: false
			}));
			tokens.push({ key: `search:${this.searchQuery}`, text: `Search: ${this.searchQuery}` });
		}

		if (this.statusKeys.length > 0) {
			filters.push(new Filter({
				filters: this.statusKeys.map(s => new Filter("status", FilterOperator.EQ, s)),
				and: false
			}));
			for (const s of this.statusKeys) {
				tokens.push({ key: `status:${s}`, text: `Status: ${s}` });
			}
		}

		if (this.customerIds.length > 0) {
			filters.push(new Filter({
				filters: this.customerIds.map(id => new Filter("customer_ID", FilterOperator.EQ, id)),
				and: false
			}));
			const cb = this.byId("customerFilter") as MultiComboBox;
			for (const id of this.customerIds) {
				const item = cb.getItemByKey(id);
				const text = item ? item.getText() : id;
				tokens.push({ key: `customer:${id}`, text: `Customer: ${text}` });
			}
		}

		if (this.amountMin > 0 || this.amountMax < 100000) {
			filters.push(new Filter("grossAmount", FilterOperator.BT, this.amountMin, this.amountMax));
			tokens.push({ key: `amount:${this.amountMin}-${this.amountMax}`, text: `Amount: ${this.amountMin}-${this.amountMax}` });
		}

		if (this.openOnly) {
			filters.push(new Filter({
				filters: [
					new Filter("status", FilterOperator.EQ, "New"),
					new Filter("status", FilterOperator.EQ, "InProgress")
				],
				and: false
			}));
			tokens.push({ key: "open:on", text: "Open only" });
		}

		const table = this.byId("ordersTable") as Table;
		const binding = table.getBinding("items") as ListBinding;
		binding.filter(filters);

		const stateModel = this.getView().getModel("state") as JSONModel;
		stateModel.setProperty("/tokens", tokens);
	}

	public onItemPress(event: ListBase$ItemPressEvent): void {
		const item = event.getParameter("listItem");
		const ctx = item.getBindingContext() as Context;
		const orderId = ctx.getProperty("ID") as number;
		this.getRouter().navTo("object", { orderId: encodeURIComponent(String(orderId)) });
	}
}
