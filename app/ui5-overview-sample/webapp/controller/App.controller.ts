import BaseController from "./BaseController";

/**
 * @namespace ui5overviewsample.controller
 */
export default class App extends BaseController {
	public onInit(): void {
		this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
	}
}
