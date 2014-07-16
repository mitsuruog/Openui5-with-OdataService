<a name="whatisodata">1. ODataとは何か？</a>
========
<http://www.odata.org/> - Odata公式より。

> OData is a standardized protocol for creating and consuming data APIs. OData builds on core protocols like HTTP and commonly accepted methodologies like REST. The result is a uniform way to expose full-featured data APIs.  

> ODataとはデータAPIを作成し利用するために標準化されたプロトコルです。ODataはHTTPプロトコルと、一般的に浸透しているRESTという方法論で構成されています。つまり、これらのフル機能を満たすDataAPIを公開するために統一された方法です。

フロントエンドエンジニアの私が感じるODataとは、次のような印象です。

「Webシステムにおける、フロントエンドとバックエンドとの面倒なAjax問い合わせの手続きを標準化したプロトコル」

**ここにバックエンドを切り離して抽象化する昨今の開発の流れをかく**

旧来、システムからRDBMSへのデータアクセスの方法を統一するために標準化された方法としてODBCが存在しますが、これと同様に、フロントエンドからバックエンドへのデータアクセスを統一化するために標準化された方法が「OData」と言えます。つまり、ODBCのWeb版です。  
特にODataにおいては、検索、ページングに代表されるデータの取得を行うときに、その標準化のメリットを感じる事が多いでしょう。

ODataに関する情報はこちらが公式サイトとなっています。  
<http://www.odata.org/>

### ODataを理解するための用語

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

**[[⬆]](#table)**