import type {SuiteConfiguration} from "sap/ui/test/starter/config";
export default {
	name: "QUnit test suite for the UI5 Application: ui5lropsample",
	defaults: {
		page: "ui5://test-resources/ui5lropsample/Test.qunit.html?testsuite={suite}&test={name}",
		qunit: {
			version: 2
		},
		sinon: {
			version: 4
		},
		ui5: {
			language: "EN",
			theme: "sap_horizon"
		},
		coverage: {
			only: ["ui5lropsample/"],
			never: ["test-resources/ui5lropsample/"]
		},
		loader: {
			paths: {
				"ui5lropsample": "../"
			}
		}
	},
	tests: {
		"unit/unitTests": {
			title: "Unit tests for ui5lropsample"
		},
		"integration/opaTests": {
			title: "Integration tests for ui5lropsample"
		}
	}
} satisfies SuiteConfiguration;
