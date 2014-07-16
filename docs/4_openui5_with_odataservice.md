<a name="productlist">5. OpenUI5とODataServiceの統合</a>
========


### ODataServiceのendpoint定義

まず、本アプリケーションにて利用するODataServiceのendpointを定義します。endpointの定義はアプリケーションで共用するため、`Componemt.coffee`の`init`内に記述します。

*Componemt.coffee:init()*
```coffeescript
init: ->
  
  ...

  # ここにOdataServiceのエンドポイントを設定します
  # /V3/Northwind/Northwind.svc/
  endpoint = sap.ui.model.odata.ODataModel "/V3/Northwind/Northwind.svc/", true
  @setModel endpoint
```
`sap.ui.model.odata.ODataModel`を作成し、名前なしのグローバルModelとしてアプリケーション内に保持します。

**[[⬆]](#table)**

<a name="install">5.1. 導入</a>
========

**[[⬆]](#table)**

<a name="project">5.2. プロジェクトの説明</a>
========

**[[⬆]](#table)**