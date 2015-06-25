<a name="whatisodata">2. なぜODataが注目されるべきなのか？</a>
========

2. Why now OData is Cool?

まず、なぜ今ODataが注目されるべきなのか、OpenUI5というUIフレームワークとODataが統合された時、何かメリットなのか少し背景など話しながら理解していきましょう。

First, Why now OData is cool, and What the benefits of an integrated OpenUI5 and OData.  
Let's talk background in order to understand.

### ODataとは何か？

<http://www.odata.org/> - Odata公式より。

> OData is a standardized protocol for creating and consuming data APIs. OData builds on core protocols like HTTP and commonly accepted methodologies like REST. The result is a uniform way to expose full-featured data APIs.  

> ODataとはデータAPIを作成し利用するために標準化されたプロトコルです。ODataはHTTPプロトコルと、一般的に浸透しているRESTという方法論で構成されています。つまり、これらのフル機能を満たすDataAPIを公開するために統一された方法です。

つまり、

「Webシステムにおける、フロントエンドとバックエンドとの面倒なAjax問い合わせの手続きを標準化したプロトコル」とも言えます。

新しい概念ではなので、難しく感じる必要はありません。  
日常的に行われているAjaxリクエストを仕様として標準化したものです。

システムをいくつかの機能レイアーで分割することで、抽象化して標準化することは以前からよく行われてきたことです。
代表的なものはODBCです。ODBCはアプリケーションからRDBMSへのデータアクセスの手続きを標準化したものです。

「OData」はODBCのWeb版です。
フロントエンドとバックエンドとの間のデータアクセスについて標準化しています。
ODataはMicrosoft、IBM、SAP、Citrix社が中心となって、データアクセスプロトコルの業界標準となるように動いています。

ODataに関する情報はこちらが公式サイトはこちらです。  
<http://www.odata.org/>

What is OData?

> OData is a standardized protocol for creating and consuming data APIs. OData builds on core protocols like HTTP and commonly accepted methodologies like REST. The result is a uniform way to expose full-featured data APIs.  

In other words,  
"Protocol standardizes the procedure cumbersome Ajax request between the back-end and front-end in Web system development."

Not a new concept. You needn't feel hard.
Ajax requests are done on a daily basis to standardized specifications.

Dividing the system in some functional layer, abstraction and standardization is traditionally has done well.  
ODBC is typical. ODBC is a standardized application procedures for data access to the RDBMS.

OData is a Web version of the ODBC. The standardization of data access between the front-end and back-end.

OData is movement of the data access protocol become industry standards such as. Microsoft, IBM, SAP, Citrix has a central role to.

### 昨今のWeb開発の流れ

昨今、Ajaxの登場によりWebアプリケーションにおいて、フロントエンドの重要性が増してきていることは周知の事実かと思います。  
それに伴ってフロントエンドの実装が高度化、複雑化してきたこともあり、ソリューションの1つとして様々なクライアントMVCフレームワーク（以下、クライアントMVC）が台頭してきました。

最近のフロントエンド開発ではYeoman、Bower、Gruntなどのエコシステムが作られています。しかし、フレームワークのロックインが強いことも事実です。
新しいWeb技術を企業向けWebシステムで活用していくためには、サーバーサイドのWebAPIも含んだ統合が必要だと考えています。

Trends in Web development.

Would do well known fact that increasingly importance of front-end Web application, with the advent of Ajax.

Advanced front-end implementation accordingly and has become complicated. One solution for many client MVC framework (the client MVC) has appeared.

Front-end development recently made ecosystems such as Yeoman, Bower, and Grunt. However, lock-in framework that is true.
I think that new Web technologies for enterprise Web systems, including the WebAPI for server-side integration is required.

### データアクセス方法を標準化するODataの登場

ODataは、様々なAjaxでのデータアクセス方法を標準化しています。これはデータアクセスが主な、企業向けWebアプリケーションをターゲットに考えた場合、非常に有利に働きます。
なぜなら、フロントエンドのデータアクセスに関する様々な変更(例えば、クエリパラメータの追加など)を、ODataという仕様で吸収できる可能性があるからです。

こちらは、通常のAjaxを利用したWebアプリケーションの構造です。

The emergence of OData to standardize data access methods.

OData is standardized in various Ajax data access methods. If it was target main, Enterprise Web application data access works very effectively.
This is because various data access front end changes (for example, query parameters added, etc.) to absorb an OData specification may be.

Here is a typical Ajax　based Web application structure

![ODataを利用しない場合](img/2-1.png)

ODataを使わない場合、フロントエンドを構築する一部にクライアントMVCが導入され、クライアントMVCを中心に統合されている状態でした。しかし、バックエンドとのWebAPIの設計、実装についてはそれぞれの案件ごとに対応している状況で、バックエンドも含めた形の統合とはほど遠い姿でした。

ではODataを利用した場合はどうでしょうか？
![ODataを利用する場合](img/2-2.png)

ODataを利用する場合、バックエンドがカスタムのWebAPIからOdataServiceと呼ばれるものに置き換わり、フロントエンドとバックエンドのデータアクセスについて標準化とライブラリによる隠蔽が可能です。  
（ちなみに、JavascriptにてODataを利用する場合、デファクトなJavascriptライブラリは[datajs](http://datajs.codeplex.com/)です。）  
しかし、ODataに対するURLパラメータの設定や、ODataから受け取ったデータのUIへのレンダリングは実装する必要があり、ODataのメリットより仕様の複雑さの方が目立つ状況でした。
このような状況のためか、ODataに対する世間の注目度はいまいちだったような気がします。

### UIフレームワークとODataの統合

そこで登場したものがODataをサポートするUIフレームの登場です。  
ここでのUIフレームワークとは、従来のクライアントMVCの機能を持ち、UIコンポーネントも持つものです。  
特徴としては、WebAPIから取得したデータを元に自動でUIを構築し、UI側の操作をダイレクトにバックエンドに連携できる機能を持っています。  
ODataをサポートする代表的なUIフレームワークとしてOpenUI5があります。

OpenUI5とODataを組み合わせた場合は次のようになります。
![ODataとOpenUi5利用する場合](img/2-3.png)

ODataとOpenUI5を組み合わせることで、バックエンドのデータアクセス部分からUIの変更まで隠蔽することが可能となりました。  
アプリケーション開発者は面倒なバックエンドとの同期について頭を悩ませる事なく、ビジネスロジックの構築に専念できます。

このようにバックエンドとフロントエンドを統合した形は、企業向けWebアプリケーション構築のソリューションとして可能性を感じます。  
OpenUI5というパートナーを得たことで、ODataの仕様は本当の意味で「使える」ものになりました。

**[[⬆]](#table)**
