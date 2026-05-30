<div align="center">

# 🛒 SAP Fiori Elements Samples — Sales Order Edition

**A curated collection of SAP Fiori Elements floorplan samples — running on a single SAP CAP (Node.js) Sales Order / Inventory backend.**

[![SAP CAP](https://img.shields.io/badge/SAP%20CAP-9.x-0a6ed1?logo=sap&logoColor=white)](https://cap.cloud.sap)
[![SAPUI5](https://img.shields.io/badge/SAPUI5-1.148-0a6ed1?logo=sap&logoColor=white)](https://sapui5.hana.ondemand.com)
[![Fiori Elements](https://img.shields.io/badge/Fiori%20Elements-floorplans-0a6ed1?logo=sap&logoColor=white)](https://sapui5.hana.ondemand.com/sdk/#/topic/03265b0408e2432c9571d6b3feb6b1fd)
[![Node.js](https://img.shields.io/badge/Node.js-%3E%3D20-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](#license)

_One CAP service. Six Fiori Elements apps + one freestyle UI5 app. Real-world side-by-side enterprise scenario._

</div>

---

## 🎯 What is this?

This repository is a **learning-by-example playground** for SAP Fiori Elements, built around a domain that mirrors how many enterprises actually run side-by-side extension projects: **Sales Order & Inventory Management**.

Each subfolder under `app/` is a self-contained sample showcasing a different **Fiori Elements floorplan** (Overview Page, List Report / Object Page, Analytical List Page, Object Page, Worklist, Custom extensions) plus one freestyle SAPUI5 app for comparison. All apps share **one CAP backend** (`SalesOrders`, `SalesOrderItems`, `Customers`, `Products`, `ProductCategories`, `SalesOrgs`), so each floorplan can be evaluated against a realistic, business-meaningful dataset.

> 💡 Pick a floorplan, run one `npm run watch-…` command, and the app opens in your browser with live data and live reload.

---

## ✨ Samples at a glance

### Fiori Elements floorplans

| 📦 App | 🧭 Floorplan | 💡 What it demonstrates | ▶️ Run |
|---|---|---|---|
| [`fe-overview-sample`](app/fe-overview-sample) | **Overview Page (OVP)** | 8 cards: open orders list, revenue chart, orders by status, stock donut, open-order KPI, static links, top customers stack, product quick-view | `npm run watch-fe-overview-sample` |
| [`fe-lrop-sample`](app/fe-lrop-sample) | **List Report / Object Page** | Sales orders list with filter bar → header → composition of items | `npm run watch-fe-lrop-sample` |
| [`fe-alp-sample`](app/fe-alp-sample) | **Analytical List Page** | Aggregated `ListOfOrders` with charts (by customer / sales org / currency) + KPIs | `npm run watch-fe-alp-sample` |
| [`fe-objectpage-sample`](app/fe-objectpage-sample) | **Object Page** | Sales-order OP with header data points + cross-navigation | `npm run watch-fe-objectpage-sample` |
| [`fe-worklist-sample`](app/fe-worklist-sample) | **Worklist** | "Open orders" — `Status = New / InProgress` only | `npm run watch-fe-worklist-sample` |
| [`fe-custom-sample`](app/fe-custom-sample) | **Custom extensions** | Custom search + table page over sales orders | `npm run watch-fe-custom-sample` |

### Freestyle UI5 (TypeScript)

| 📦 App | 🧭 Pattern | 💡 What it demonstrates | ▶️ Run |
|---|---|---|---|
| [`ui5-lrop-sample`](app/ui5-lrop-sample) | **Freestyle LROP** | Hand-built worklist + object page in plain SAPUI5 + TS — direct comparison to the FE LROP sample | `npm run watch-ui5-lrop-sample` |

### Production / admin apps

| 📦 App | Purpose |
|---|---|
| [`manage-orders`](app/manage-orders) | CRUD + draft for `SalesOrders` (admins) |
| [`manage-customers`](app/manage-customers) | CRUD + draft for `Customers` |
| [`browse-orders`](app/browse-orders) | Read-only catalog browse |
| [`product-categories`](app/product-categories) | Hierarchical product-category maintenance |

> Each sample is wired through `app/services.cds` and shares annotations from `app/common.cds`.

---

## 🚀 Quick start

```bash
# 1. install
npm install

# 2. pick a sample and run
npm run watch-fe-overview-sample
# → opens http://localhost:4004/feoverviewsample/index.html
```

That's it. SQLite is used out-of-the-box for local development; sample data in `db/data/` is loaded automatically on every restart.

To start just the CAP server (no UI auto-open):

```bash
npm start
```

Then visit the sandbox launchpad at:

```
http://localhost:4004/launchpage.html
```

---

## 🧱 Project layout

```
.
├── db/                 # Domain model & sample data
│   ├── schema.cds          → SalesOrders, SalesOrderItems, Customers,
│   │                          Products, ProductCategories, SalesOrgs
│   └── data/               → CSV seed data (~25 orders, ~60 items, etc.)
├── srv/                # CAP services
│   ├── cat-service.cds     → CatalogService (read-only) + submitOrder action
│   ├── admin-service.cds   → AdminService   (CRUD, draft-enabled)
│   └── sample-services.cds → Service variants used by individual samples
├── app/                # Fiori Elements apps + shared annotations
│   ├── common.cds          → Shared UI annotations
│   ├── services.cds        → Aggregates per-app annotations
│   ├── fe-overview-sample/    🖼️  OVP
│   ├── fe-lrop-sample/        📋  List Report / Object Page
│   ├── fe-alp-sample/         📊  Analytical List Page
│   ├── fe-objectpage-sample/  📄  Object Page
│   ├── fe-worklist-sample/    ✅  Worklist
│   ├── fe-custom-sample/      🛠️  Custom extensions
│   ├── ui5-lrop-sample/       🧩  Freestyle SAPUI5 (TypeScript)
│   ├── manage-orders/         🔧  Per-app annotation module (admin)
│   ├── manage-customers/      🔧  Per-app annotation module (admin)
│   ├── browse-orders/         🔧  Per-app annotation module (read-only)
│   ├── product-categories/    🔧  Hierarchical category maintenance
│   └── router/                → approuter for launchpad sandbox
├── mta.yaml            # Cloud Foundry deployment descriptor
└── xs-security.json    # XSUAA configuration
```

---

## 🧬 Domain model

Defined in [`db/schema.cds`](db/schema.cds) under the namespace `sap.capire.salesorders`:

- **SalesOrders** — order header with `orderNo`, `orderDate`, `customer`, `salesOrg`, `status`, `grossAmount`, `currency`; **draft-enabled** via `@fiori.draft.enabled`
- **SalesOrderItems** — composition of `SalesOrders`; `position`, `product`, `quantity`, `unitPrice`, `netAmount`
- **Customers** — `name`, `country`, `city`, `email`, `customerSince`, `segment`
- **Products** — `name`, `category`, `price`, `currency`, `stock`, `supplier`, localized `description`; computed `stockCriticality` (1/2/3) used by OVP donut chart
- **ProductCategories** — self-referencing hierarchical code list (parent / children)
- **SalesOrgs** — code list (`code`, `name`, `country`)

`Status` is constrained to: `New`, `InProgress`, `Shipped`, `Completed`, `Cancelled`.

## 🔌 Services

| Service | File | Purpose |
|---|---|---|
| `CatalogService` | [`srv/cat-service.cds`](srv/cat-service.cds) | Read-only `ListOfOrders` projection + `submitOrder` action |
| `AdminService` | [`srv/admin-service.cds`](srv/admin-service.cds) | Full CRUD on SalesOrders, Customers, Products, ProductCategories |
| `CatalogServiceLrop` | [`srv/sample-services.cds`](srv/sample-services.cds) | Endpoint for `fe-lrop-sample` |
| `CatalogServiceObjectpage` | [`srv/sample-services.cds`](srv/sample-services.cds) | Endpoint for `fe-objectpage-sample` |
| `CatalogServiceAlp` | [`srv/sample-services.cds`](srv/sample-services.cds) | Aggregation-enabled service for `fe-alp-sample` |
| `CatalogServiceCustom` | [`srv/sample-services.cds`](srv/sample-services.cds) | Endpoint for `fe-custom-sample` |
| `CatalogServiceOverview` | [`srv/sample-services.cds`](srv/sample-services.cds) | OData V4 service exposed in **V2** via `@cap-js-community/odata-v2-adapter` (OVP requires V2) |

The `submitOrder(orderID)` action transitions an order from `New` → `InProgress` and decrements stock for each item.

---

## 🛠️ Tech stack

- **Backend** — [SAP CAP](https://cap.cloud.sap) (`@sap/cds` ^9), SQLite (`@cap-js/sqlite`) for local dev
- **OData V2 adapter** — [`@cap-js-community/odata-v2-adapter`](https://github.com/cap-js-community/odata-v2-adapter) (required by OVP)
- **UI** — SAPUI5 1.148 + Fiori Elements floorplans, served via [`cds-plugin-ui5`](https://www.npmjs.com/package/cds-plugin-ui5)
- **Deployment** — MTA / Cloud Foundry, HTML5 Application Repository, XSUAA

---

## ☁️ Build & deploy (Cloud Foundry)

```bash
npm run build      # build MTA archive (mbt)
npm run deploy     # cf deploy mta_archives/archive.mtar
npm run undeploy   # cleanly remove app + services + brokers
```

Requires the [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/) and an entitlement to deploy HTML5 / XSUAA / Destination services.

---

## 📋 Prerequisites

- **Node.js** ≥ 20 (compatible with `@sap/cds` v9)
- **`@sap/cds-dk`** — install globally with `npm i -g @sap/cds-dk`
- For deployment: **Cloud Foundry CLI** + **MTA Build Tool** (`mbt`, included as devDependency)

---

## 📚 Learn more

- 🌐 [SAP Cloud Application Programming Model](https://cap.cloud.sap)
- 🌐 [SAP Fiori Elements Documentation](https://sapui5.hana.ondemand.com/sdk/#/topic/03265b0408e2432c9571d6b3feb6b1fd)
- 🌐 [SAPUI5 Demo Kit](https://sapui5.hana.ondemand.com)
- 🌐 [OData V2 Adapter for CAP](https://github.com/cap-js-community/odata-v2-adapter)

---

## 📝 License

Released under the **MIT License**. This project is a sample / demo and is provided **as-is** without warranty.

<div align="center">

Made with ☕ and `@sap/cds` — happy coding!

</div>
