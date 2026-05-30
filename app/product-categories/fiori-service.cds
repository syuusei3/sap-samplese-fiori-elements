using { sap.capire.salesorders.ProductCategories } from '../../db/schema';

annotate ProductCategories with @cds.search: {name};
annotate ProductCategories with @readonly;
annotate ProductCategories with {
  name @title: '{i18n>Category}';
}

// Lists
annotate ProductCategories with @(
  Common.SemanticKey : [name],
  UI.SelectionFields : [name],
  UI.LineItem : [
   { Value: name, Label: '{i18n>Name}' },
  ],
);

// Details
annotate ProductCategories with @(UI : {
  Identification : [{ Value: name }],
  HeaderInfo     : {
    TypeName       : '{i18n>Category}',
    TypeNamePlural : '{i18n>Categories}',
    Title          : { Value: name },
    Description    : { Value: ID }
  }
});


// Tree Views
using from './tree-view';
using from './value-help';
