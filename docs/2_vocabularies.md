2. ODataを理解するための用語集
========

これからのODataに関する技術的な内容を理解するための用語集です。なかにはOData標準にはないもので、私が作成した造語も含まれますのでご注意ください。

* OdataService
	* Odataを返すバックエンドシステムのこと。今回のチュートリアルで利用する [NorthWind OdataService](http://services.odata.org/V3/Northwind/Northwind.svc/) はOdataを提供する代表的なオープンデータサービス
* endpoint
	* OdataServiceのURL
* Metadata
	* OdataServiceが提供するODataのデータモデル。通常はXML。
* EntityType
	* ODataのデータ構造体
* Entities
	* EntityTypeの実際のデータ。リスト形式。
* Entity
	* Entitiesの中の1件。
