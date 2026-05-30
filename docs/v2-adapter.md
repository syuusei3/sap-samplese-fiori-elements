# OData V2 アダプターの仕組み

このプロジェクトでは CAP (Node.js) が標準で公開する OData V4 サービスに加えて、
OData V2 が必要なフロントエンド（例: SAP Fiori OVP / 一部の SmartTemplate / 古い UI5 アプリ）向けに
**OData V2 エンドポイント** を併設しています。

V2 エンドポイントは CAP 自身ではなく、`@cap-js-community/odata-v2-adapter` プラグインが
V4 → V2 の変換プロキシとして動作することで実現しています。

---

## 1. 何のためのもの？

CAP Node.js のランタイムは OData V4 のみをネイティブサポートします。
ところが Fiori Elements の一部テンプレート（特に **OVP = Overview Page**）や、
SAP 内製の古いアプリ・既存のクライアントは OData V2 のメタデータ／ペイロードを前提にしています。

そこで以下の構成にします:

```
[Fiori OVP (V2 client)]  ──>  /odata/v2/<service>   ──┐
                                                       │  V2↔V4 変換
[Fiori Elements (V4)]    ──>  /odata/v4/<service>   ──┴──>  CAP runtime
```

- バックエンドのモデル・サービス定義は **V4 のまま 1 本** で書く
- V2 が欲しいクライアントだけ V2 アダプター経由でアクセスする
- V2 / V4 の URL は同じサービスを指している（メタデータ・データは自動変換）

---

## 2. このプロジェクトでの使われ方

### 2.1 依存関係 (`package.json`)

ルートの `package.json` に以下が宣言されています:

```json
{
  "dependencies": {
    "@cap-js-community/odata-v2-adapter": "^1.15.12",
    "@sap/cds": "^9"
  }
}
```

`@cap-js-community/odata-v2-adapter` は **CDS プラグイン** として作られているため、
依存にあるだけで `cds-serve` 起動時に自動ロードされます。
コード上で明示的に `require(...)` したり Express にマウントしたりする必要はありません。

### 2.2 起動時に何が起こるか

`npm start` (= `cds-serve`) を実行すると以下が動きます:

1. CAP がモデルをコンパイルし、`@path` で指定された各 V4 サービスを
   `/odata/v4/...` 配下にマウント。
2. プラグインが CAP のサービス一覧を読み取り、各 V4 サービスに対応する
   V2 エンドポイントを `/odata/v2/...` 配下に **追加でマウント**。
3. V2 エンドポイントへのリクエストが来ると、プラグインが
   - URL（`$filter`, `$expand`, key の表記など）
   - リクエスト／レスポンスボディ
   - メタデータ (`$metadata`)
   - エラーフォーマット
   を V2 ⇄ V4 で相互変換し、内部的には CAP の V4 サービスを呼び出します。

つまり **V2 の実装を別途用意する必要はない** ところがこの仕組みの肝です。

### 2.3 サービス定義との関係

このリポジトリでは `srv/sample-services.cds` で V4 サービスを定義しています。
V2 を必要とするサービスにはコメントが添えられています:

```cds
// Used by app/fe-overview-sample
// OVP requires OData V2; @cap-js-community/odata-v2-adapter exposes
// a V2 endpoint at /odata/v2/catalog-overview alongside the V4 one.
service CatalogServiceOverview @(path: '/odata/v4/catalog-overview') {
  @readonly
  entity ListOfBooks as projection on my.Books excluding { ... };
}
```

`@(path: '/odata/v4/catalog-overview')` という V4 用のパスを定義するだけで、
アダプターが自動的に `/odata/v2/catalog-overview` という V2 用パスを
ペアで生やしてくれます。

### 2.4 フロントエンドからの参照

OVP サンプル (`app/fe-overview-sample`) のように V2 が必要な側は
`webapp/manifest.json` の `dataSources` で **V2 のパス** を指定します:

```jsonc
"dataSources": {
  "mainService": {
    "uri": "/odata/v2/catalog-overview/",
    "type": "OData",
    "settings": { "odataVersion": "2.0" }
  }
}
```

V4 で十分な他のサンプル (LROP, Object Page, ALP, Custom など) は
そのまま `/odata/v4/...` を `odataVersion: "4.0"` で参照します。

---

## 3. URL 一覧（このリポジトリの実例）

| サービス (cds)                | V4 エンドポイント                  | V2 エンドポイント (アダプター生成) | 利用するアプリ              |
|------------------------------|----------------------------------|----------------------------------|------------------------------|
| `CatalogServiceOverview`     | `/odata/v4/catalog-overview`     | `/odata/v2/catalog-overview`     | `app/fe-overview-sample` (OVP) |
| `CatalogServiceLrop`         | `/odata/v4/catalog-lrop`         | `/odata/v2/catalog-lrop`         | `app/fe-lrop-sample`         |
| `CatalogServiceObjectpage`   | `/odata/v4/catalog-objectpage`   | `/odata/v2/catalog-objectpage`   | `app/fe-objectpage-sample`   |
| `CatalogServiceCustom`       | `/odata/v4/catalog-custom`       | `/odata/v2/catalog-custom`       | `app/fe-custom-sample`       |
| `CatalogServiceAlp`          | `/odata/v4/catalog-alp`          | `/odata/v2/catalog-alp`          | `app/fe-alp-sample`          |

V2 側を実際に使っているのは現状 OVP サンプルのみですが、
他のサービスでも上記 V2 URL は同じく動作します（V4 を主として使う想定）。

メタデータ確認:

- `GET /odata/v2/catalog-overview/$metadata` → V2 形式の EDMX
- `GET /odata/v4/catalog-overview/$metadata` → V4 形式の EDMX

---

## 4. 動作確認の手順

```bash
# 起動
npm run watch-fe-overview-sample
# あるいは
npm start
```

別ターミナル / ブラウザで:

```
http://localhost:4004/odata/v2/catalog-overview/$metadata
http://localhost:4004/odata/v2/catalog-overview/ListOfBooks?$top=1
http://localhost:4004/odata/v4/catalog-overview/$metadata
```

V2 側は `<edmx:Edmx Version="1.0">` / `m:properties` のような V2 表現、
V4 側は `<edmx:Edmx Version="4.0">` / JSON フラット表現になっていれば成功です。

---

## 5. 主な制約・注意点

- **モデルは V4 で書く**: V2 用の CDS を別に書く必要はないし、書いてはいけません。
  すべての挙動 (Draft、アクション、ナビゲーションなど) は V4 サービス側で実装し、
  V2 側はその投影として自動生成されます。
- **V4 にしかない型・機能は V2 側で表現できない場合がある**:
  例えば一部の構造化型・複合キー以外のキー表現、`Edm.Date` / `Edm.TimeOfDay` の
  扱いなどはアダプターの変換ルールに従います。OVP / 古い UI5 で見える形に
  落ちるかは `$metadata` で確認してください。
- **アダプターは Node.js ランタイム前提**: CAP Java 側には別の仕組み
  (ネイティブ V2 アダプター / `cds-feature-odata-v2`) があるため、
  本ドキュメントの構成は Java プロジェクトには直接適用できません。
- **本番デプロイ時**: `mta.yaml` で `srv` モジュールを動かしている限り、
  プラグインも一緒に同梱されるので追加設定は不要です。`approuter` の
  ルーティングで `/odata/v2/**` と `/odata/v4/**` の両方を `srv` に
  通していることを確認してください。

---

## 6. 参考リンク

- プラグイン (npm): https://www.npmjs.com/package/@cap-js-community/odata-v2-adapter
- リポジトリ: https://github.com/cap-js-community/odata-v2-adapter
- CAP 公式 (CAP Node.js は V4 ネイティブ): https://cap.cloud.sap/docs/node.js/
- Fiori OVP (V2 前提のテンプレート): https://sapui5.hana.ondemand.com/#/topic/2cda7bdf509c4f589abd365091e7a1ee
