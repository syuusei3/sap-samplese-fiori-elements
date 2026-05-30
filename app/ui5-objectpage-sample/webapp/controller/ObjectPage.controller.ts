import BaseController from "./BaseController";
import Route from "sap/ui/core/routing/Route";
import { Route$PatternMatchedEvent } from "sap/ui/core/routing/Route";

/**
 * @namespace ui5objectpagesample.controller
 */
export default class ObjectPage extends BaseController {

	public onInit(): void {
		const route = this.getRouter().getRoute("object") as Route;
		route.attachPatternMatched(this.onObjectMatched, this);
	}

	private onObjectMatched(event: Route$PatternMatchedEvent): void {
		const args = event.getParameter("arguments") as { orderId: string };
		const orderId = decodeURIComponent(args.orderId);
		const path = `/SalesOrders(${orderId})`;
		this.getView().bindElement({
			path,
			parameters: {
				$expand: "customer,salesOrg,currency,items($expand=product,currency)"
			}
		});
	}
}
