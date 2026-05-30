// Value help with Tree View
using from '../manage-orders/fiori-service';
annotate AdminService.Products:category with @Common.ValueList.PresentationVariantQualifier: 'VH';
annotate AdminService.ProductCategories with @UI.PresentationVariant #VH: {
  RecursiveHierarchyQualifier : 'ProductCategoriesHierarchy',
};
