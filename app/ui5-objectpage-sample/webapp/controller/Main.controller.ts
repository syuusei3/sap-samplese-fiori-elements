import BaseController from "./BaseController";
import ODataModel from "sap/ui/model/odata/v4/ODataModel";
import ODataListBinding from "sap/ui/model/odata/v4/ODataListBinding";
import Context from "sap/ui/model/odata/v4/Context";
import MessageBox from "sap/m/MessageBox";

/**
 * @namespace ui5objectpagesample.controller
 */
export default class Main extends BaseController {

	public async onInit(): Promise<void> {
		try {
			const model = this.getOwnerComponent().getModel() as ODataModel;
			const binding = model.bindList("/SalesOrders", undefined, undefined, undefined, {
				$select: "ID",
				$top: 1
			}) as ODataListBinding;
			const contexts = await binding.requestContexts(0, 1) as Context[];
			if (contexts.length === 0) {
				MessageBox.warning("No SalesOrders available.");
				return;
			}
			const firstId = contexts[0].getProperty("ID") as number;
			this.navTo("object", { orderId: String(firstId) }, true);
		} catch (e: unknown) {
			MessageBox.error("Failed to load first SalesOrder: " + String(e));
		}
	}
}
