import BaseController from "./BaseController";
import Route from "sap/ui/core/routing/Route";
import { Route$PatternMatchedEvent } from "sap/ui/core/routing/Route";

/**
 * @namespace ui5alpsample.controller
 */
export default class ObjectPage extends BaseController {

	public onInit(): void {
		const route = this.getRouter().getRoute("object") as Route;
		route.attachPatternMatched(this.onObjectMatched, this);
	}

	private onObjectMatched(event: Route$PatternMatchedEvent): void {
		const args = event.getParameter("arguments") as { orderId: string };
		const orderId = decodeURIComponent(args.orderId);
		this.getView().bindElement({
			path: `/ListOfOrders(${orderId})`,
			parameters: {
				$expand: "customer,salesOrg,currency"
			}
		});
	}
}
