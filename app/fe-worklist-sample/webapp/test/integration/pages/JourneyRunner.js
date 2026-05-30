sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"feworklistsample/test/integration/pages/ListOfBooksList",
	"feworklistsample/test/integration/pages/ListOfBooksObjectPage",
	"feworklistsample/test/integration/pages/Books_textsObjectPage"
], function (JourneyRunner, ListOfBooksList, ListOfBooksObjectPage, Books_textsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('feworklistsample') + '/test/flp.html#app-preview',
        pages: {
			onTheListOfBooksList: ListOfBooksList,
			onTheListOfBooksObjectPage: ListOfBooksObjectPage,
			onTheBooks_textsObjectPage: Books_textsObjectPage
        },
        async: true
    });

    return runner;
});

