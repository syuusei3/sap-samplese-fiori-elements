using {AdminService} from '../../srv/admin-service';

annotate AdminService.Customers with @odata.draft.enabled;

////////////////////////////////////////////////////////////////////////////
//
//	Customer Object Page
//
annotate AdminService.Customers with @(UI : {
  HeaderInfo : {
    TypeName       : '{i18n>Customer}',
    TypeNamePlural : '{i18n>Customers}',
    Title          : { Value : name },
    Description    : { Value : country }
  },
  Facets : [
    {
      $Type  : 'UI.ReferenceFacet',
      Label  : '{i18n>Details}',
      Target : '@UI.FieldGroup#Details'
    },
    {
      $Type  : 'UI.ReferenceFacet',
      Label  : '{i18n>Orders}',
      Target : 'orders/@UI.LineItem'
    },
  ],
  FieldGroup #Details : {Data : [
    { Value : name },
    { Value : segment },
    { Value : country },
    { Value : city },
    { Value : email },
    { Value : customerSince },
  ]},
});

annotate AdminService.Customers with {
  segment @Common.Label : '{i18n>Segment}'
}

// Workaround for Fiori popup for asking user to enter a new UUID on Create
annotate AdminService.Customers with { ID @Core.Computed; }
