# 開発で詰まったところ・知見メモ

このリポジトリで Fiori Elements の各テンプレート (OVP / LROP / Object Page / Custom / ALP) を
CAP (Node.js) バックエンドの上に並べて動かすときに、実際にハマった点と解決策をまとめておく。
別のサンプルを足したり、別プロジェクトに同じパターンを移植するときの参考に。

---

## 1. OVP (Overview Page) は OData V2 でしか動かない

- **症状:** OVP テンプレートで Fiori app を作ろうとすると、UI5 内部で V2 メタデータ前提の処理が走り、
  `/odata/v4/...` を指定しても画面が組み立たない。
- **原因:** OVP は SAP Fiori Elements の floorplan のうち **OData V4 対応がいまだに来ていない** 数少ない
  テンプレート。新しい sap.fe ベースではなく旧 SmartTemplate 系のままなので V2 を要求する。
- **解決:** CAP は V4 ネイティブなので、`@cap-js-community/odata-v2-adapter` を入れて
  `/odata/v2/<service>` を併設し、OVP の `manifest.json` の `dataSources.mainService` を
  V2 URL + `odataVersion: "2.0"` に向ける。
- 詳細は [`docs/v2-adapter.md`](./v2-adapter.md) 。
- **見分け方のコツ:** `manifest.json` の `sourceTemplate.id` が `@sap/generator-fiori:ovp` なら V2 必須。
  `lrop` / `worklist` / `objectpage` / `alp` / `feop` 系は V4 で OK。

---

## 2. ALP のチャートで `Measures: [stock]` が動かない

- **症状:** ブラウザコンソールで連鎖的に以下が出て、画面が真っ白:
  - `TypeError: Cannot read properties of undefined (reading '$Type')` ＠ `_AnnotationHelperExpression.fetchCurrencyOrUnit`
  - `Error: Please configure DynamicMeasures for the chart` ＠ `sap.fe.macros.Chart`
  - `Cannot read properties of null (reading 'data' / 'getActions')`
- **原因:** SAP UI5 1.148 系の `sap.fe.macros.Chart` は ALP チャートに **`DynamicMeasures` を必須**化している。
  古い `Measures: [stock]` 形式だと、内部で「measure の通貨/単位を取りに行く」コードパスに入ってしまい、
  同エンティティの `price` に `@Measures.ISOCurrency: currency_code` がついている影響で `stock` の `$Type` を
  undefined で読みに行って落ちる。
- **解決:** `Analytics.AggregatedProperty` を別途宣言し、`UI.Chart` から `DynamicMeasures` で参照する:

  ```cds
  annotate service.ListOfBooks with @(
    Analytics.AggregatedProperty #totalStock : {
      Name                : 'totalStock',
      AggregationMethod   : 'sum',
      AggregatableProperty: 'stock',
      ![@Common.Label]    : 'Total Stock'
    },
    UI.Chart #alpChart : {
      ChartType          : #Column,
      Dimensions         : [genre_ID],
      DimensionAttributes: [{ Dimension: genre_ID, Role: #Category }],
      DynamicMeasures    : ['@Analytics.AggregatedProperty#totalStock'],
      MeasureAttributes  : [{
        DynamicMeasure: '@Analytics.AggregatedProperty#totalStock',
        Role          : #Axis1
      }]
    }
  );
  ```

- **ハマりポイント:** `MeasureAttributes` のキーは `Measure` ではなく **`DynamicMeasure`**。
  `Measure: stock` のままだと「DynamicMeasures が無い」エラーになる。
- **`Aggregation.ApplySupported`** も忘れず宣言すること（CAP は集計用の `$apply` トランスフォーメーションを
  これで申告するため）。実例は `app/fe-alp-sample/annotations.cds` を参照。

---

## 3. ALP Chart Dimension の `$expand is not yet supported` 警告

- **症状:** ALP は描画されるが、コンソールに以下が出続ける:
  - `$expand is not yet supported. Text Property: genre/name from an association cannot be used for the dimension genre_ID`
  - 同じく `author/name`
- **原因:** Chart の Dimension `genre_ID` には **テキスト** として表示する文字列が要る。
  CDS では `Books.genre` association に `@Common.Text: genre.name` が付いており、これが FK プロパティ
  `genre_ID` に伝播する。MDC Chart は集計時に `$apply=...` クエリを投げるが、その中で `$expand` は
  サポートされないため、association 越しに `genre.name` を引けず警告になる。
- **解決:** サービス側 projection に **フラットなテキスト列** を追加し、annotation で association ではなく
  そのフラット列を指すように上書き:

  ```cds
  // srv/sample-services.cds
  service CatalogServiceAlp @(path: '/odata/v4/catalog-alp') {
    @readonly
    entity ListOfBooks as
      projection on my.Books {
        *,
        genre.name  as genreName  : String,
        author.name as authorName : String
      }
      excluding { descr, createdBy, modifiedBy };
  }

  // app/fe-alp-sample/annotations.cds
  annotate service.ListOfBooks with {
    genre  @Common.Text : genreName  @Common.TextArrangement : #TextOnly;
    author @Common.Text : authorName @Common.TextArrangement : #TextOnly;
  };
  ```

- **ハマりポイント:** `@Common.Text` を **FK 側 (`genre_ID`)** に直接 annotate しようとしても効かない。
  CAP の December 2024+ 仕様で **association に付けた annotation が FK にコピーされる** ため、
  `genre` / `author` (アソシエーション本体) を annotate するのが正解。
- **副次的なルール:** Chart の Dimension に紐づく Text は **必ず同一エンティティのフラット列** にする。
  集計クエリを投げる画面では association 越しの text は基本動かないと考えてよい。

---

## 4. `Component-preload.js` 404 / i18n_en.properties 404 / `/sap/bc/lrep/...` 404

開発モード (`cds watch`) で Fiori Elements を立ち上げると、致命的ではないが大量に出る 404 ログ。
本番環境ではどれも問題にならないが、ノイズが多くて本物のエラーが埋もれるので、
サンプルアプリレベルで以下を仕込んでクリーンにしている:

| 警告 | 抑制方法 | 場所 |
|---|---|---|
| `Component-preload.js` 404 | `data-sap-ui-xx-componentPreload="off"` を bootstrap に追加 | `webapp/index.html` |
| `i18n_en_US.properties` / `i18n_en.properties` 404 | `manifest.json` の i18n 設定を `{ bundleUrl, supportedLocales: [""], fallbackLocale: "" }` 形式に書き換え | `webapp/manifest.json` |
| `/sap/bc/lrep/flex/...` 404 | `"sap.ui5": { "flexEnabled": false }` | `webapp/manifest.json` |
| `S/CUBE is not yet supported` | UI5 内部 INFO ログ。抑止できないので諦める | — |

実例は `app/fe-alp-sample/webapp/index.html` と `app/fe-alp-sample/webapp/manifest.json` 。

---

## 5. アプリごとの service 分割と annotation の置き場所

- このリポジトリでは **アプリ 1 つに service 1 つ** という分割を採用している
  (`CatalogServiceLrop`, `CatalogServiceObjectpage`, `CatalogServiceCustom`,
  `CatalogServiceAlp`, `CatalogServiceOverview`)。`srv/sample-services.cds` 参照。
- これは **アプリ固有の annotation がぶつかるのを避ける** ための分割。たとえば ALP では
  `genre_ID` の Text を `genreName` に上書きしたいが、他のアプリではそれが要らない。
  サービスを分けておけば、`app/fe-alp-sample/annotations.cds` の `annotate service.ListOfBooks ...` が
  ALP のサービスにだけ効く。
- `app/services.cds` で各アプリの annotations を `using` で取り込んで全体集約している。
  新しいアプリを追加するときは
  1. `srv/sample-services.cds` に専用 service を生やす
  2. `app/<app-name>/annotations.cds` を作って `using <NewService> as service from '../../srv/sample-services';`
  3. `app/services.cds` に `using from './<app-name>/annotations';` を追加
  という 3 ステップでいける。

---

## 6. 起動と確認のコマンド集

```bash
# 個別アプリを開く（ルートで）
npm run watch-fe-overview-sample    # OVP (V2)
npm run watch-fe-lrop-sample        # LROP (V4)
npm run watch-fe-objectpage-sample  # Object Page (V4)
npm run watch-fe-custom-sample      # Custom Page (V4)
npm run watch-fe-alp-sample         # Analytical List Page (V4)

# OData metadata を直接確認
curl http://localhost:4004/odata/v4/catalog-alp/\$metadata
curl http://localhost:4004/odata/v2/catalog-overview/\$metadata
```

annotation の出力を確認したいときは EDMX に出してみるのが速い:

```bash
npx cds compile srv/ app/ --to edmx -s CatalogServiceAlp > /tmp/alp.xml
```

CAP MCP を使っているなら `mcp__cap__search_model { name: "ListOfBooks", kind: "entity" }` で
コンパイル後の CSN（注釈含む）を直接覗ける。これが annotation の効き具合を確かめる一番速い方法。

---

## 7. 参考リンク

- CAP docs (Node.js): https://cap.cloud.sap/docs/node.js/
- Fiori Elements Building Blocks: https://sapui5.hana.ondemand.com/#/topic/8e9c2f44137c4da3b29d4a45a4f81fef
- ALP テンプレート概要: https://sapui5.hana.ondemand.com/#/topic/3d33684b08ca4490b26a844b6ce19b83
- OVP 概要 (V2 前提): https://sapui5.hana.ondemand.com/#/topic/2cda7bdf509c4f589abd365091e7a1ee
- `@cap-js-community/odata-v2-adapter`: https://github.com/cap-js-community/odata-v2-adapter
