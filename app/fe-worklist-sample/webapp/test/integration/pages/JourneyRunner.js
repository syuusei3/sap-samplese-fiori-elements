sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"feworklistsample/test/integration/pages/ListOfOrdersList",
	"feworklistsample/test/integration/pages/ListOfOrdersObjectPage"
], function (JourneyRunner, ListOfOrdersList, ListOfOrdersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('feworklistsample') + '/test/flp.html#app-preview',
        pages: {
			onTheListOfOrdersList: ListOfOrdersList,
			onTheListOfOrdersObjectPage: ListOfOrdersObjectPage
        },
        async: true
    });

    return runner;
});
