import UIComponent from "sap/ui/core/UIComponent";
import models from "./model/models";
import Device from "sap/ui/Device";

/**
 * @namespace ui5objectpagesample
 */
export default class Component extends UIComponent {
	public static metadata = {
		manifest: "json",
		interfaces: ["sap.ui.core.IAsyncContentCreation"]
	};

	private contentDensityClass: string;

	public init(): void {
		super.init();
		this.setModel(models.createDeviceModel(), "device");
		this.getRouter().initialize();
	}

	public getContentDensityClass(): string {
		if (this.contentDensityClass === undefined) {
			if (document.body.classList.contains("sapUiSizeCozy") || document.body.classList.contains("sapUiSizeCompact")) {
				this.contentDensityClass = "";
			} else if (!Device.support.touch) {
				this.contentDensityClass = "sapUiSizeCompact";
			} else {
				this.contentDensityClass = "sapUiSizeCozy";
			}
		}
		return this.contentDensityClass;
	}
}
