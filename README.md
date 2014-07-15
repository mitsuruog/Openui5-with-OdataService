Openui5-with-OdataService
=========================

How to integrate OdataService in OpenUI5

1. [ODataとは何か？](#whatisOdata)
1. [ODataを理解するための用語集](#vocabularies)
1. [ODataの構造](#basic)
1. [ODataServiceをURLで操作する](#manipulating)
1. [OpenUI5とODataServiceの統合](#openui5withodata)
	- 5.1. [はじめに]  
	- 5.2. [雛形]  
	- 5.3. [商品リストの実装](#productlist_impl)  
		* 5.3.a [商品リストの取得](#productlist)  
		* 5.3.b [商品名での検索](#search)  
		* 5.3.c [商品リストのソート、フィルタ](#sortandfilter)  
		* 5.3.d [商品詳細への画面遷移](#gotodetail)  
	- 5.4. [商品詳細の実装](#product_impl)  
		* 5.4.a [商品情報の参照](#product)  
		* 5.4.b [カテゴリ情報の参照](#category)  
		* 5.4.c [メーカー情報の参照](#supplier)  

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

<a name="vocabularies">2. ODataを理解するための用語集</a>
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


<a name="basic">3. ODataの構造</a>
========

ODataはHTTPをベースに構成されているため、1つのバックエンドとのやり取りを見る限る通常のHTTPとなんら変わりはありません。  
バックエンドへの問い合わせは通常の`GET`、`POST`、`PUT`、`DELETE`で行い、返されるデータも`xml`、 `json`、`atom`形式です。

しかし、ODataはバックエンドとの間の複数のHTTP問い合わせを統合して標準化しています。そしてODataを返すバックエンドがODataServiceです。
ODataServiceには、提供するデータAPIのI/F定義を外部に公開するMetadataと呼ばれるでデータ構造体を持っています。  

ODataを理解する上では、このMetadataの構造を理解する事が必須です。この章ではMetadataを見ながらのODataのデータモデルについて基本的なことを説明します。  
今回のチュートリアルで利用するNorthwindのMetadataをベースに進めていきます。Metadataはこちらで確認できます。
<http://services.odata.org/V3/Northwind/Northwind.svc/$metadata>

## EntityTypeとEntities

### EntityType

EntityTypeはODataを構成する最も小さなデータ構造体です。RDBMSのスキーマ定義に該当します。Northwindの`Category`と`Product` EntityTypeを見てみます。

*Category*
````xml
<EntityType Name="Category">
	<Key>
		<PropertyRef Name="CategoryID"/>
	</Key>
	<Property xmlns:p6="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="CategoryID" Type="Edm.Int32" Nullable="false" p6:StoreGeneratedPattern="Identity"/>
	<Property Name="CategoryName" Type="Edm.String" Nullable="false" MaxLength="15" FixedLength="false" Unicode="true"/>
	<Property Name="Description" Type="Edm.String" MaxLength="Max" FixedLength="false" Unicode="true"/>
	<Property Name="Picture" Type="Edm.Binary" MaxLength="Max" FixedLength="false"/>
	<NavigationProperty Name="Products" Relationship="NorthwindModel.FK_Products_Categories" ToRole="Products" FromRole="Categories"/>
</EntityType>
````

*Product*
````xml
<EntityType Name="Product">
	<Key>
		<PropertyRef Name="ProductID"/>
	</Key>
	<Property xmlns:p6="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="ProductID" Type="Edm.Int32" Nullable="false" p6:StoreGeneratedPattern="Identity"/>
	<Property Name="ProductName" Type="Edm.String" Nullable="false" MaxLength="40" FixedLength="false" Unicode="true"/>
	<Property Name="SupplierID" Type="Edm.Int32"/>
	<Property Name="CategoryID" Type="Edm.Int32"/>
	<Property Name="QuantityPerUnit" Type="Edm.String" MaxLength="20" FixedLength="false" Unicode="true"/>
	<Property Name="UnitPrice" Type="Edm.Decimal" Precision="19" Scale="4"/>
	<Property Name="UnitsInStock" Type="Edm.Int16"/>
	<Property Name="UnitsOnOrder" Type="Edm.Int16"/>
	<Property Name="ReorderLevel" Type="Edm.Int16"/>
	<Property Name="Discontinued" Type="Edm.Boolean" Nullable="false"/>
	<NavigationProperty Name="Category" Relationship="NorthwindModel.FK_Products_Categories" ToRole="Categories" FromRole="Products"/>
	<NavigationProperty Name="Order_Details" Relationship="NorthwindModel.FK_Order_Details_Products" ToRole="Order_Details" FromRole="Products"/>
	<NavigationProperty Name="Supplier" Relationship="NorthwindModel.FK_Products_Suppliers" ToRole="Suppliers" FromRole="Products"/>
</EntityType>
````
`EntityType`の中に`key`と`Property`が存在するような、良く見るデータ構造体です。  
`NavigationProperty`はこのEntityTypeが他のEntityTypeと関連がある場合の情報で、RDBMSの外部キーに相当するものです。後述する`Association`にて利用されます。

### Entities

EntitiesはEntityTypeのデータ構造体を実際のデータにしたものです。 
Javaで置き換えるとクラスがEntityTypeで、Entitiesはそのインスタンスに該当します。そのため、Entitiesはリストになるケースが多いです。
以下が、`Product`のEntitiesの抜粋です。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json>

````javascript
{
	odata.metadata: "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
	value: [{
			ProductID: 1,
			ProductName: "Chai",
			SupplierID: 1,
			CategoryID: 1,
			QuantityPerUnit: "10 boxes x 20 bags",
			UnitPrice: "18.0000",
			UnitsInStock: 39,
			UnitsOnOrder: 0,
			ReorderLevel: 10,
			Discontinued: false
		}, {
			ProductID: 2,
			ProductName: "Chang",
			SupplierID: 1,
			CategoryID: 1,
			QuantityPerUnit: "24 - 12 oz bottles",
			UnitPrice: "19.0000",
			UnitsInStock: 17,
			UnitsOnOrder: 40,
			ReorderLevel: 25,
			Discontinued: false
		},

		...

	}]
}
````
注目は、問い合わせURLが`Product`ではなく`Products`となっているところです。こちらは、後述する`EntitySet`にて取り上げます。

## Association

### Association

2つ以上のEntiryTypeの関連を定義したものです。RDBMSのスキーマ定義における外部キーに相当します。先ほどの2つのEntityType`Category`と`Entity`には関連がありますので、それを見てみましょう。

````xml
<Association Name="FK_Products_Categories">
	<End Type="NorthwindModel.Category" Role="Categories" Multiplicity="0..1"/>
	<End Type="NorthwindModel.Product" Role="Products" Multiplicity="*"/>
	<ReferentialConstraint>
		<Principal Role="Categories">
			<PropertyRef Name="CategoryID"/>
		</Principal>
		<Dependent Role="Products">
			<PropertyRef Name="CategoryID"/>
		</Dependent>
	</ReferentialConstraint>
</Association>
````
2つの関連するEntityTypeとそれぞれのKeyが定義されています。`Multiplicity`にて関連の多重度が定義されています。いままでRDBMSに携わっていた方であれば、容易に理解できると思います。

## EntityConteinerとAssociationSet、EntitySet

### EntityConteiner

ODataServiceが外部に公開するI/Fを納めたコンテナ定義です。  
上で挙げた`EntityType`や`Association`はODataService内部の定義であって、外部の利用者はEntityConteinerにて公開されているI/Fを利用します。

### EntitySet

EntityTypeの外部公開I/F名。`Product`の場合、EntitySetの名前が`Products`となっているため、外部からアクセスする場合は`Products`を利用します。慣例でEntityTypeの複数系で、Entitiesを表すことが多いようです。

以下にEntityConteinerとEntitySetを抜粋します。

````xml
<EntityContainer xmlns:p6="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="NorthwindEntities" m:IsDefaultEntityContainer="true" p6:LazyLoadingEnabled="true">
	<EntitySet Name="Categories" EntityType="NorthwindModel.Category"/>
	<EntitySet Name="CustomerDemographics" EntityType="NorthwindModel.CustomerDemographic"/>
	<EntitySet Name="Customers" EntityType="NorthwindModel.Customer"/>
	<EntitySet Name="Employees" EntityType="NorthwindModel.Employee"/>
	<EntitySet Name="Order_Details" EntityType="NorthwindModel.Order_Detail"/>
	<EntitySet Name="Orders" EntityType="NorthwindModel.Order"/>
	<EntitySet Name="Products" EntityType="NorthwindModel.Product"/>
	<EntitySet Name="Regions" EntityType="NorthwindModel.Region"/>
	<EntitySet Name="Shippers" EntityType="NorthwindModel.Shipper"/>

	.....

</EntityContainer>
````

### AssociationSet

EntitySetと同じくAssociationの外部公開I/F名。以下が`FK_Products_Categories`のAssociationSet定義です。AssociationSetもEntityConteiner内部に格納されています。


````xml
	<AssociationSet Name="FK_Products_Categories" Association="NorthwindModel.FK_Products_Categories">
		<End Role="Categories" EntitySet="Categories"/>
		<End Role="Products" EntitySet="Products"/>
	</AssociationSet>
````

ODataServiceを利用した実際の開発では、このようにODataServiceが提供するMetadataを参照しながら行っていきます。  
これまでのWeb開発での、RDBMSのスキーマ定義を参照しながら開発することと何ら変わりない事が理解できると思います。


<a name="manipulating">4. ODataServiceをURLで操作する</a>
========

早速、ODataServiceを操作してみましょう。先述した通り、ODataはデータAPIであるため、ブラウザのアドレスバーにURLを入力することによってアクセスすることが出来ます。 
URLのクエリパラメータをいくつか追加していくことでODataServiceの振る舞いを柔軟に変える事が出来ます。実際に検索、ページングなどデータの取得シーンを想定し、ODataが持つポテンシャルを十分体験してみてください。  

ODataServiceはNorthwindを利用します。Metadataを確認する場合はこちらを参照してください。
<http://services.odata.org/V3/Northwind/Northwind.svc/$metadata>

> ブラウザではなくデータAPIのテスト専用に作られたRESTクライアントツールを利用することを推奨します。こちらのChrome extentionsの[POATMAN](https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm)は、非常に操作しやすくRESTクライアントとして一番のおすすめです。  
ブラウザのみでデータアクセスする際は、こちらのChrome extentionsの[JSONVIew](https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc)だけでもインストールしておくといいでしょう。

## OdataService

### endpoint

では、早速ODataServiceを提供するendpointの情報を取得します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/>

結果は以下の通りです。  
（結果は冗長なため、後半部分を割愛しながら説明していきます。ご了承ください。）
````xml
<?xml version="1.0" encoding="utf-8"?>
<service xml:base="http://services.odata.org/V3/Northwind/Northwind.svc/" 
    xmlns="http://www.w3.org/2007/app" 
    xmlns:atom="http://www.w3.org/2005/Atom">
    <workspace>
        <atom:title>Default</atom:title>
        <collection href="Categories">
            <atom:title>Categories</atom:title>
        </collection>
        <collection href="CustomerDemographics">
            <atom:title>CustomerDemographics</atom:title>
        </collection>
        <collection href="Customers">
            <atom:title>Customers</atom:title>
        </collection>
        <collection href="Employees">
            <atom:title>Employees</atom:title>
        </collection>
        <collection href="Order_Details">
            <atom:title>Order_Details</atom:title>
        </collection>
        <collection href="Orders">
            <atom:title>Orders</atom:title>
        </collection>
        <collection href="Products">
            <atom:title>Products</atom:title>
        </collection>
        <collection href="Regions">
            <atom:title>Regions</atom:title>
        </collection>

        ...

    </workspace>
</service>
````
<http://services.odata.org/V3/Northwind/Northwind.svc/>こちらのURLがODataServiceを提供するendpointを表しています。  
結果は`EntityContainer`と同等のものが返されていることが分かります。これがNorthwindのODataServiceが提供するデータAPIのI/F定義です。  
より詳細な内容は次の`Metadata`を取得して確認します。

### Metadata
Metadataを取得するためにはendpointのURLの後ろに`$metadata`を付与します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/$metadata>

結果は以下の通りです。
````xml
This XML file does not appear to have any style information associated with it. The document tree is shown below.
<edmx:Edmx xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx" Version="1.0">
	<edmx:DataServices xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" m:DataServiceVersion="1.0" m:MaxDataServiceVersion="3.0">
		<Schema xmlns="http://schemas.microsoft.com/ado/2008/09/edm" Namespace="NorthwindModel">
			<EntityType Name="Category">
				<Key>
					<PropertyRef Name="CategoryID"/>
				</Key>
				<Property xmlns:p6="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="CategoryID" Type="Edm.Int32" Nullable="false" p6:StoreGeneratedPattern="Identity"/>
				<Property Name="CategoryName" Type="Edm.String" Nullable="false" MaxLength="15" FixedLength="false" Unicode="true"/>
				<Property Name="Description" Type="Edm.String" MaxLength="Max" FixedLength="false" Unicode="true"/>
				<Property Name="Picture" Type="Edm.Binary" MaxLength="Max" FixedLength="false"/>
				<NavigationProperty Name="Products" Relationship="NorthwindModel.FK_Products_Categories" ToRole="Products" FromRole="Categories"/>
			</EntityType>
			<EntityType Name="CustomerDemographic">
				<Key>
					<PropertyRef Name="CustomerTypeID"/>
				</Key>
				<Property Name="CustomerTypeID" Type="Edm.String" Nullable="false" MaxLength="10" FixedLength="true" Unicode="true"/>
				<Property Name="CustomerDesc" Type="Edm.String" MaxLength="Max" FixedLength="false" Unicode="true"/>
				<NavigationProperty Name="Customers" Relationship="NorthwindModel.CustomerCustomerDemo" ToRole="Customers" FromRole="CustomerDemographics"/>
			</EntityType>

			...

			<Association Name="FK_Products_Categories">
				<End Type="NorthwindModel.Category" Role="Categories" Multiplicity="0..1"/>
				<End Type="NorthwindModel.Product" Role="Products" Multiplicity="*"/>
				<ReferentialConstraint>
					<Principal Role="Categories">
						<PropertyRef Name="CategoryID"/>
					</Principal>
					<Dependent Role="Products">
						<PropertyRef Name="CategoryID"/>
					</Dependent>
				</ReferentialConstraint>
			</Association>

			...

		</Schema>
		<Schema xmlns="http://schemas.microsoft.com/ado/2008/09/edm" Namespace="ODataWebV3.Northwind.Model">
			<EntityContainer xmlns:p6="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="NorthwindEntities" m:IsDefaultEntityContainer="true" p6:LazyLoadingEnabled="true">
				<EntitySet Name="Categories" EntityType="NorthwindModel.Category"/>
				<EntitySet Name="CustomerDemographics" EntityType="NorthwindModel.CustomerDemographic"/>
				<EntitySet Name="Customers" EntityType="NorthwindModel.Customer"/>
				<EntitySet Name="Employees" EntityType="NorthwindModel.Employee"/>
				<EntitySet Name="Order_Details" EntityType="NorthwindModel.Order_Detail"/>
				<EntitySet Name="Orders" EntityType="NorthwindModel.Order"/>
				<EntitySet Name="Products" EntityType="NorthwindModel.Product"/>
				
				...

				<AssociationSet Name="FK_Products_Categories" Association="NorthwindModel.FK_Products_Categories">
					<End Role="Categories" EntitySet="Categories"/>
					<End Role="Products" EntitySet="Products"/>
				</AssociationSet>
				
				...

			</EntityContainer>
		</Schema>
	</edmx:DataServices>
</edmx:Edmx>
````
MetadataはXMLで返されます。  
OdataServiceは複数のEntityを統合して公開できる能力を持っているため、複数のEntityを利用する場合は、EntityごとにODataServiceを作成してクライアントマッシュアップで統合するよりは、単一のODataServiceの中に含めてしまう方が経験的に良いと考えています。

## Entitiesアクセス

### Entities
では、ProductsのEntitiesを取得してみましょう。このパートが最も一般的なフロント側からのデータアクセス要求シーンだと思います。  
EntitiesにアクセスするためにはendpointのURLの後ろに`EntitySet名`を付与します。   
<http://services.odata.org/V3/Northwind/Northwind.svc/Products>

結果は以下の通りです。
````xml
<?xml version="1.0" encoding="utf-8"?>
<feed xml:base="http://services.odata.org/V3/Northwind/Northwind.svc/" 
    xmlns="http://www.w3.org/2005/Atom" 
    xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" 
    xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">
    <id>http://services.odata.org/V3/Northwind/Northwind.svc/Products</id>
    <title type="text">Products</title>
    <updated>2014-07-13T04:55:40Z</updated>
    <link rel="self" title="Products" href="Products" />
    <entry>
        <id>http://services.odata.org/V3/Northwind/Northwind.svc/Products(1)</id>
        <category term="NorthwindModel.Product" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme" />
        <link rel="edit" title="Product" href="Products(1)" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Category" type="application/atom+xml;type=entry" title="Category" href="Products(1)/Category" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Order_Details" type="application/atom+xml;type=feed" title="Order_Details" href="Products(1)/Order_Details" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Supplier" type="application/atom+xml;type=entry" title="Supplier" href="Products(1)/Supplier" />
        <title />
        <updated>2014-07-13T04:55:40Z</updated>
        <author>
            <name />
        </author>
        <content type="application/xml">
            <m:properties>
                <d:ProductID m:type="Edm.Int32">1</d:ProductID>
                <d:ProductName>Chai</d:ProductName>
                <d:SupplierID m:type="Edm.Int32">1</d:SupplierID>
                <d:CategoryID m:type="Edm.Int32">1</d:CategoryID>
                <d:QuantityPerUnit>10 boxes x 20 bags</d:QuantityPerUnit>
                <d:UnitPrice m:type="Edm.Decimal">18.0000</d:UnitPrice>
                <d:UnitsInStock m:type="Edm.Int16">39</d:UnitsInStock>
                <d:UnitsOnOrder m:type="Edm.Int16">0</d:UnitsOnOrder>
                <d:ReorderLevel m:type="Edm.Int16">10</d:ReorderLevel>
                <d:Discontinued m:type="Edm.Boolean">false</d:Discontinued>
            </m:properties>
        </content>
    </entry>
    <entry>
        <id>http://services.odata.org/V3/Northwind/Northwind.svc/Products(2)</id>
        <category term="NorthwindModel.Product" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme" />
        <link rel="edit" title="Product" href="Products(2)" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Category" type="application/atom+xml;type=entry" title="Category" href="Products(2)/Category" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Order_Details" type="application/atom+xml;type=feed" title="Order_Details" href="Products(2)/Order_Details" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Supplier" type="application/atom+xml;type=entry" title="Supplier" href="Products(2)/Supplier" />
        <title />
        <updated>2014-07-13T04:55:40Z</updated>
        <author>
            <name />
        </author>
        <content type="application/xml">
            <m:properties>
                <d:ProductID m:type="Edm.Int32">2</d:ProductID>
                <d:ProductName>Chang</d:ProductName>
                <d:SupplierID m:type="Edm.Int32">1</d:SupplierID>
                <d:CategoryID m:type="Edm.Int32">1</d:CategoryID>
                <d:QuantityPerUnit>24 - 12 oz bottles</d:QuantityPerUnit>
                <d:UnitPrice m:type="Edm.Decimal">19.0000</d:UnitPrice>
                <d:UnitsInStock m:type="Edm.Int16">17</d:UnitsInStock>
                <d:UnitsOnOrder m:type="Edm.Int16">40</d:UnitsOnOrder>
                <d:ReorderLevel m:type="Edm.Int16">25</d:ReorderLevel>
                <d:Discontinued m:type="Edm.Boolean">false</d:Discontinued>
            </m:properties>
        </content>
    </entry>

		...

</feed>
````

### $format
先ほどのデータはXML形式でしたので、JSONで取得してみましょう。URLパラメータに`$format=json`を渡します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },
        {
            "ProductID": 2,
            "ProductName": "Chang",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "24 - 12 oz bottles",
            "UnitPrice": "19.0000",
            "UnitsInStock": 17,
            "UnitsOnOrder": 40,
            "ReorderLevel": 25,
            "Discontinued": false
        },

        ...

````
`$format`パラメータを渡すことでレスポンスのデータ形式を指定できます。以降のURLアクセスはJSONで行います。

### $select
次に取得データ項目の取捨選択の方法です。  
プルダウンを作るためにデータ取得する想定だとします。先ほどのデータでは必要ない項目まで取得されてしまうため、必要な項目だけにしぼってデータを取得しましょう。今回はProductIDとProductNameが欲しいとします。URLパラメータに`$select=ProductID,ProductName`を渡します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$select=ProductID,ProductName>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products&$select=ProductID,ProductName",
    "value": [
        {
            "ProductID": 1,
            "ProductName": "Chai"
        },
        {
            "ProductID": 2,
            "ProductName": "Chang"
        },
        {
            "ProductID": 3,
            "ProductName": "Aniseed Syrup"
        },
        {
            "ProductID": 4,
            "ProductName": "Chef Anton's Cajun Seasoning"
        },
        {
            "ProductID": 5,
            "ProductName": "Chef Anton's Gumbo Mix"
        },
        {
            "ProductID": 6,
            "ProductName": "Grandma's Boysenberry Spread"
        },
        {
            "ProductID": 7,
            "ProductName": "Uncle Bob's Organic Dried Pears"
        },

       ...

````
`$select`に複数のデータ項目を渡したい場合は`,（カンマ）`で区切って渡してください。後述するAssociationを絡めた複雑なパターンにも対応できます。

### $count
問い合わせるデータの件数を取得したい場合はURLに`$count`を付与します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products/$count>

結果は以下の通りです。
````js
77
````

### $top
ここからはページングを想定したデータアクセスを想定して話を進めていきます。  
5件ごとにページ遷移すると仮定して最初の5件を取得します。URLパラメータに`$top=5`を渡します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$top=5>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },
        {
            "ProductID": 2,
            "ProductName": "Chang",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "24 - 12 oz bottles",
            "UnitPrice": "19.0000",
            "UnitsInStock": 17,
            "UnitsOnOrder": 40,
            "ReorderLevel": 25,
            "Discontinued": false
        },
        {
            "ProductID": 3,
            "ProductName": "Aniseed Syrup",
            "SupplierID": 1,
            "CategoryID": 2,
            "QuantityPerUnit": "12 - 550 ml bottles",
            "UnitPrice": "10.0000",
            "UnitsInStock": 13,
            "UnitsOnOrder": 70,
            "ReorderLevel": 25,
            "Discontinued": false
        },
        {
            "ProductID": 4,
            "ProductName": "Chef Anton's Cajun Seasoning",
            "SupplierID": 2,
            "CategoryID": 2,
            "QuantityPerUnit": "48 - 6 oz jars",
            "UnitPrice": "22.0000",
            "UnitsInStock": 53,
            "UnitsOnOrder": 0,
            "ReorderLevel": 0,
            "Discontinued": false
        },
        {
            "ProductID": 5,
            "ProductName": "Chef Anton's Gumbo Mix",
            "SupplierID": 2,
            "CategoryID": 2,
            "QuantityPerUnit": "36 boxes",
            "UnitPrice": "21.3500",
            "UnitsInStock": 0,
            "UnitsOnOrder": 0,
            "ReorderLevel": 0,
            "Discontinued": true
        }
    ]
}
````
ProductIDが`1~5`の5件取得していることが分かります。

### $skip
では次の5件を取得します。URLパラメータに`$top=5&$skip=5`を渡します。
$skipを指定することで最初の5件をスキップします。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$top=5&$skip=5>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 6,
            "ProductName": "Grandma's Boysenberry Spread",
            "SupplierID": 3,
            "CategoryID": 2,
            "QuantityPerUnit": "12 - 8 oz jars",
            "UnitPrice": "25.0000",
            "UnitsInStock": 120,
            "UnitsOnOrder": 0,
            "ReorderLevel": 25,
            "Discontinued": false
        },
        {
            "ProductID": 7,
            "ProductName": "Uncle Bob's Organic Dried Pears",
            "SupplierID": 3,
            "CategoryID": 7,
            "QuantityPerUnit": "12 - 1 lb pkgs.",
            "UnitPrice": "30.0000",
            "UnitsInStock": 15,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },
        {
            "ProductID": 8,
            "ProductName": "Northwoods Cranberry Sauce",
            "SupplierID": 3,
            "CategoryID": 2,
            "QuantityPerUnit": "12 - 12 oz jars",
            "UnitPrice": "40.0000",
            "UnitsInStock": 6,
            "UnitsOnOrder": 0,
            "ReorderLevel": 0,
            "Discontinued": false
        },
        {
            "ProductID": 9,
            "ProductName": "Mishi Kobe Niku",
            "SupplierID": 4,
            "CategoryID": 6,
            "QuantityPerUnit": "18 - 500 g pkgs.",
            "UnitPrice": "97.0000",
            "UnitsInStock": 29,
            "UnitsOnOrder": 0,
            "ReorderLevel": 0,
            "Discontinued": true
        },
        {
            "ProductID": 10,
            "ProductName": "Ikura",
            "SupplierID": 4,
            "CategoryID": 8,
            "QuantityPerUnit": "12 - 200 ml jars",
            "UnitPrice": "31.0000",
            "UnitsInStock": 31,
            "UnitsOnOrder": 0,
            "ReorderLevel": 0,
            "Discontinued": false
        }
    ]
}
````
今度はProductIDが`6~10`の5件取得していることが分かります。

### $orderby
次は、orderby指定をしてみます。`ProductID`の降順を指定します。URLパラメータに`$orderby=ProductID desc`を渡します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$orderby=ProductID desc>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 77,
            "ProductName": "Original Frankfurter grüne Soße",
            "SupplierID": 12,
            "CategoryID": 2,
            "QuantityPerUnit": "12 boxes",
            "UnitPrice": "13.0000",
            "UnitsInStock": 32,
            "UnitsOnOrder": 0,
            "ReorderLevel": 15,
            "Discontinued": false
        },
        {
            "ProductID": 76,
            "ProductName": "Lakkalikööri",
            "SupplierID": 23,
            "CategoryID": 1,
            "QuantityPerUnit": "500 ml",
            "UnitPrice": "18.0000",
            "UnitsInStock": 57,
            "UnitsOnOrder": 0,
            "ReorderLevel": 20,
            "Discontinued": false
        },
        {
            "ProductID": 75,
            "ProductName": "Rhönbräu Klosterbier",
            "SupplierID": 12,
            "CategoryID": 1,
            "QuantityPerUnit": "24 - 0.5 l bottles",
            "UnitPrice": "7.7500",
            "UnitsInStock": 125,
            "UnitsOnOrder": 0,
            "ReorderLevel": 25,
            "Discontinued": false
          },

          ...

````
`$orderby`のパラメータには`プロパティ名 順序`を指定します、順序を指定しない場合は`asc`指定となります。  
複数指定する場合は`,(カンマ)`で区切って指定してください。  
試しにSupplierID, CategoryIDの昇順でデータを取得しましょう。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$orderby=SupplierID, CategoryID>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },
        {
            "ProductID": 2,
            "ProductName": "Chang",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "24 - 12 oz bottles",
            "UnitPrice": "19.0000",
            "UnitsInStock": 17,
            "UnitsOnOrder": 40,
            "ReorderLevel": 25,
            "Discontinued": false
        },
        {
            "ProductID": 3,
            "ProductName": "Aniseed Syrup",
            "SupplierID": 1,
            "CategoryID": 2,
            "QuantityPerUnit": "12 - 550 ml bottles",
            "UnitPrice": "10.0000",
            "UnitsInStock": 13,
            "UnitsOnOrder": 70,
            "ReorderLevel": 25,
            "Discontinued": false
        },

        ...

````

### $filter
次は、検索処理を想定したデータ取得です。Entitiesに対して何らかのfilter処理を加える場合、URLパラメータに`$filter`を渡します。`$filter`のパラメータは`プロパティ名 演算子 条件値`を設定します。  
試しにSupplierIDが1のデータを取得してみましょう。

<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$filter=SupplierID eq 1>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },
        {
            "ProductID": 2,
            "ProductName": "Chang",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "24 - 12 oz bottles",
            "UnitPrice": "19.0000",
            "UnitsInStock": 17,
            "UnitsOnOrder": 40,
            "ReorderLevel": 25,
            "Discontinued": false
        },
        {
            "ProductID": 3,
            "ProductName": "Aniseed Syrup",
            "SupplierID": 1,
            "CategoryID": 2,
            "QuantityPerUnit": "12 - 550 ml bottles",
            "UnitPrice": "10.0000",
            "UnitsInStock": 13,
            "UnitsOnOrder": 70,
            "ReorderLevel": 25,
            "Discontinued": false
        }
    ]
}
````
SupplierIDが1に該当するデータが取得できていることが分かります。次は、SupplierIDが1でUnitsInStockが20以上のデータを取得してみましょう。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$filter=SupplierID eq 1 and UnitsInStock ge 20>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        }
    ]
}
````
このように$filterを利用することで検索処理に対して柔軟に対応できることがわかりました。  
$filterには他にも多くの演算子が存在しています。詳細は[こちら](http://www.odata.org/documentation/odata-version-2-0/uri-conventions/#FilterSystemQueryOption)で確認できます。

### $expand
最後に、Associationに関連するデータアクセスの方法を学びます。  
EntitySet`Product`はmetadataを見ると`Category`と`Order_Details`と`Supplier`の3つに関連があるとされています。しかし、いままでのデータアクセスの結果を見る限り、これらの情報を取得していません。例えばProductにはSupplierIDが含まれていますが、実際に表示したい値はIDではなく名称というケースはよく遭遇すると思います。  
良くある方法では、SupplierIDをキーに逐一Supplierに対してデータを取得するか、取得データに名称を含めてしまうかですが、どちらにしても途中から気付いて変更することは面倒であることはかわりありません。

ODataには関連するデータ取得についてもURLパラメータから指定することが可能です。試しに`Category`と`Supplier`のデータを`Product`と一緒に取得してみましょう。URLパラメータに`$expand`を渡します。`$expand`のパラメータは`NavigationPropertyのname属性`を設定します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$expand=Category, Supplier>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products",
    "value": [
        {
            "Category": {
                "CategoryID": 1,
                "CategoryName": "Beverages",
                "Description": "Soft drinks, coffees, teas, beers, and ales",
                "Picture": "FRwvAAIAAAANAA4AFAAhAP////9CaXRtYXAgSW1hZ2UAUGFpbnQuUGljdHVyZQABBQAAAgAAAAcAAABQQnJ1c2gAAAAAAAAAAACgKQAAQk2YKQAAAAAAAFYAAAAoAAAArAAAAHgAAAABAAQAAAAAAAAAAACICwAAiAsAAAgAAAAIAAAA////AAD//wD/AP8AAAD/AP//AAAA/wAA/wAAAAAAAAAAABAAAAAAEAAAAAEAEAAAAAAAAAEBAQABAAAQAQAAAAEBAAEAAAAQAQAAAQAAABAQEAAQAAAQABAAAAAAAAAAAAAAEAAAAAEAAAAAAAAAEAAAAAAAAAAAAAAAEAEAEAAAAAAAAAAAAAEAEAEAABJQcHAQAAAAEAAAAAEAAQAQAAABAAAAEAAAAAAQAQAQAAAAEAEBAQEBAAAAAAAAAAAAAAEAEAAQAAAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAQECBSU2N3d3d3d3d1NTAQAQEAAQAAAAAAEBAAEAEAAQAQAQAAAAAAAQAAAAAAAAAAAQABAAEAEBAAEAAAABABAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEBQ0NXd3d3d3d3d3d3d3d3d3AQASAAEBAQAQIAAAAAAAAAAAAAAAAQAQABABAAAAAAAQABAAAAAAAAAAABABAAAAEAEAEBAQAAAAAAAAAAAAAAAAAAAAECFhd3d3d3V1dTU1NSV3d3d3d3d3AVASAAAQABAQEAAAAAAAAAAAEAAAAAAAAAEAEAEAAAAAABABAAABABABAAAQEAEAEAAAAQAAAAEAAAAAAAAAAAAAAAFBd3dzdhc3Y3d3V2d3Fwd1J3d3d3Y0AWEhAwAAAAABAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAQAAAAAAABAAAQAAAAAAAAAAAAAAAAAQBQNndXdXFwUBQAAAAQEHBxd3V3d3d3UzQQFAABAQEBAAEBABAQEAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAEBAAEAAAEAAAAAAAAAAAAAAAABA1c1MAAAAAAAAAAAAAAAAAAXF3d3d3dHBhIQEAAAAAEAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQABBwMBAQEhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEDQ1AAAAABBlNDV3dXBHdHRwAAAQd1d3cXEAAAAQEAEAAQEAAQEBAAAQAAAAAAAAAAAAEEFHcRATEDV1ACAEBHcwEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAQBQXZXdwcAAGd3d3d3ZWBAQAc3FzQ2FwFAAAEkEAAAEAAAAAEAACBAAAAgAAAQF0d2d3cAAQEHN3dXd3d3U3IQAAAAAQAAAAAAAAAQAQAAAAABAAABAAADdnZHZwAAQABXdHBBZxdHdCFAUABDQUA0MABWUSBRAQAwEBQAIQcXE3BwFDd3d3d3V3d3cRIQMXd3d3d3dwV1d3EBAAAAAQAAAAAAAAABAAAQAAAQEABHBEBEBnEAdHd3Z3d3dhQGBgB0JSQAF3d3d0dkZ3Z1IGAlAAMCFxZzd3d3d3d3d3R0dydXR3cAEBZ3d3d3d2cXMxdwMAAQEBAAAAABAAAAAAEAAAAAAABCBGAgAHdCdHd2d3d3d3Vnd3d0ZHRlZgZ2d3dmV0Z3Z1cVElNQcWZzd3dzN0Z3dXd3d3dXJ3Z3EQBRd3d3d2d3YBVxMUEDACAAEAAAAAEAEAAAAAABAQAGdEAEQEd2FHd2d3ZwZ2d3dnR2VnNHBldQV2c3VmR0Z1d3cnElIWdxdzN3Fzd3Z3dndWdHZXdXcSEQN3V3d3d3ZxcCd1MSEBAQEAABAAAAAAAQAAEBAAABB2cGAAR3Z0d3Z3Z3d1Z3Z3d3d3cEJHdnYGd3dGdHR0dnZ3dWUlZTExF3EXc3ZHd3dXZ1d3d0dxARBwF3d3d2d3dAFxc0AAAAAAAQAAEAAAAAAAEAAAAQEAR3ZUBmYFB3dndld3dndHB3R3d3Z0dmRgd3c3Z0dHZ3d3dndxcXNzU3dxdzd0d3d3d3d3R3R3ABEnEHd3d2d3d2MXFzUhASEBAQAAAAAAAAAAAAABAAAAAwBAZ2d1dnZ3UHcAZ2dHd3R3R3d3R0d3BHZ3dlZwZ0Z3dld3d3d3d3d3d3dzdmd3dHZXR3R3d3EAEDF3d3d3Z2d0E3F3EAAAAAABAAAAAAAAAAAAAAAQEAVwdEJWdlYXYAZ2cAR3BHZwdwB2d3AABHd0dzRlZEZ0VndnZ3d3d3d3d3d3c3Vmd3d3d3d3d3d3MQABB3d3d3d3d3F1NSEBAQEBAAAAAAAQABAAAAABAAd3dxIVJQMARnAHd3R2dCcEckd3ZXdWRwAHZzd0dnBHQnd3d3d3d3d3c2d3d3d2V3d3d3d3dDR3d1B1d3U3d2dnZ3AXJ3MQAAAAAAEAAAAAAAAAEAAQEAcXBwFhQgQEYAd0YEBnYWdHB3QWd0NlZ3d0AHd3YGdAdGVndnd3d3d3d1dxd3dzdHZ3VxYWEkNBAwMHd3d3dXd3UhAAABE1AAEAEAEAAAAQEAAQAAAQAAIQAXFSVnUHAHQ0BnAAUAQHZwBwZXB1d3d2d3AHd0R0ZGZWd3dnd3d3d3d3d3d3N3Z3dhAAAAATd3U1Axd3d3N3dzd1BwEAAQECEAEAAQAAAAAAABAQABABAwAGd3d2FlBgQGUEdgR2B0ZAR3ZAZwVlZ3Z3AHd2R1BHR0dnd3d3d3d3d3d3NzN0d3d3MBFzV3d3d3d3d3d1d3d3d3d2dBIEEAEAEAAAEAAAEAAAABAAEABXd0QUAABgdAZwZ2dnZ3Z3d3ZHd1Z2d3dEdwB3QHZkZ2R3dWd3d3d3d3dzc3Nzd2Rnd0d1NSd3d3Z3d3d3d3Y2VzU1NRMBAwASAwEBAAAAAAAAAAAAEAAQcAAhAAYUd2dnRkYEBAQEAGZmd2dnd3VHZ3cEZkRkQERFZ3Z2d3d3d3dzNzc3N3Z3d3Z3QkR3c3dxdxJ3cWU1dXdTQkIEABABABAAABAAEAAAAQABAAAQAwAFAAAUZmQAAAAQEDBzQ1IQEQAGVnd2cHd3AEdgR3Q3dnZ3d2d3d3d3c3NzczN1ZHdlcHU3cQB3B3AXd3ZSUnFnMAEBIQEhAwEAEDAAAAAQAQAAAAEAAAUAAGAEYWAAQAASU0NRARAQEAAAAAAAd0AAAEd0RzNzc3d1dnd3d3d3c3Nzc3dzdlZ1d3d3c3MQFnZ3B3dxd3VnF3MAEBAwAAACECEBAAAAAAAAAQAAAAAQAHdAAABBQCFBQAAAAAAAAAAAAAAAAAAwAAB3d3d3Nzc3dndnd3d3d3c3NzczNzVndnd3c3dxAXd3dxd3RwUnF2c0AwAAABAQEAAQAAAQAAAQAQAAAAEBQAVmAAAABzdWBgAAAAAAAAAAAAAAAAAARzB3d3NzM3Nzd3d0dnd3d3dzczc1N2FmZ3d3dzdzcBd3FncHc1N3dXRzUxABIQEAAAABABAQAAAQAAAAABAAQwAGVAAAAABAAUElQUBAQAAAAAAAAAAAADdzd3Z3N3c3NzN3dnd3d3d3dndkZ0ZWV1Z0d3d3N3MBcBdxB2VlQ1JzV3ABcBAwMDEBABAAAAAQAAEAEBADBwQABmAAAAAAAAAEAAAAAAAAAAAAAAAAAAd3dRRnM3M3Nzd3d3dHZ3d3d3dHRkR2RmZ3Z3d3d3JxEDEHYRcwc3Q1dHc3MBA0EFAEMDABIQAQABAQAQABJQAAAEcAAAAAAEZ0IAAAAAAAAAAAAAAAAHd3Znd3c3c3c3NzNzd2d3d3d3d2dkVnZQdXR3dldhAFcSEQFzFhFXR3djdzUQUnASUhMBAFAhAQAAEHAhAwFlAAAABkAAAAAAZ3ZAZ3ZGQAAEBkFDQXd3d2dmdhRzczczc3N3d3d2dnd3d3ZWR2dHRmRmdHd2F3UnERIRYQEAIzEhEQEFJyEBYSAUAWEDQQYBAXMHVhd3AABXAEdAAEdABEYAAABGd3BQR3d2cXNXN1Z2d3Z2dzdzd3Nzc3d3Z3d3d3d3ZWR0Z2VHdXZ3cXZwB3RlZHRzEBABEAAAElAWUhRxYXASEBIBEHB3cXN3dAAGN3AEAAB2BGdgAAAAB0B2BgB3cGd3d3dnZ2dnZ2czczM3Nzc3d0dnd3d3d3Z2d0dCRnZ0dncVdwFndndnYTEzEhMTEwE3ExcxAxIWFSUFMHMHd3d3dwAEdXdwAAAAYAZ2AABkBAAAZHQEZ0B3d3d3dnZ2dnZzdzd3c3N3d3d2d3d3d3dnR0Z2dGdHd3d0NnAXUwUyU1JScTUzU1MXAUNBQ3FhcTATEhF3cXd3d3cAFzd3AAZ2BHZncEcGRGZAAEdkAHd0d3d3d2dnZ2dnN3M3MzNzc3N3Z0Z3d3d2VGdnRwR0dnR2U3VhBzF3NXN1JTRzdBcBcDUwMTAQEBADAAFCd3d3dzd3AEd3d3AEdGBwRkQGRAAARkAGcAR2cHd3d3d2dnZ2dnM3c3d3Nzd3d3Z3d3d3d2ZWVmVnB2d2d3UHcAdWMVM0c3BzEBMhNhcDQ0NDQwcDFBcSEXd3N3d3d0AldzdwACdEcAAGQAAAAABkAGQAZ2B3d3d3Z2d2d2d3M3MzM3Nzd3dHZ3d3d3d0Z2VnRGR0d2d2NHcCcXJ1NxcXV3d1d1c1cXFxcXFxdDNhYWN3d3dzVzdABzd3NABGBmAEYAAAAAAAQABgBnZ0d3d3d3Z2Z2Z2c3c3d3c3Nzd3d0dnd3d3Z1ZWdGd0Z2V3cRcQBTcVM1N3N3d3d3d3d3d3d3d3dzd1dzdXN3d3N3N3IEd3c1AABHQERgBEAAAAAAAEAEd3QAd3dwBmdndndjMzMzMzNzd3d2Z2d3d3d3dmdHZWRldHZ2BgAAc1M3U3MXd3d3d3d3d3d3d3d3d3dzd3c3dzN1N3d0AAcXd3AABmQCRkBkAAAAAAAARkZwBHd3cAd2dmdmZ3d3d3d3Nzd3d3d3d3d3Z3dEZGdWVnZ3dTU3NSUxcTcXcXd3d3d3d3d3d3d3d3d3d3U3d3N1N3FzdwAHZzc1AAAABHRmRmVkZkRABABGQAAHdwAGdndnd3MzMzMzM3Nzd3ZnZ3d3d3d2d3d2Z2d2Vnd3FxMXUhcDcXN3d3d3d3d3d3d3d3d3U3U3cXN1N3c3d3NwAFd3cAQAdHdmd2R2Z2dmdGdgAAAAR3AAB2dmdmZnd3d3d3czd3d3Vnd3d3F3d3JgQABAQGd2EXFhMTFTU1Nxd3d3d3d3d3d3dzd1N3d3d3d1N3NxdzU3RwAABQBnBEZnd3d3Z3d3Z3d3ZWEARmEAAAZ2d2d3czMTEQEQB3d3dmZWd3dWdwQEBQUUB3dxZTY1MUcXMTU3F3d3d3d3d3d3dXdXd3d3d3d3d3c1N1N3c3FwAAAAF3YEBAQEBARgYHZ2d3YXAABHAAAHEQEQAQAAAAAAARAVcXd3Z3d3ZHASQQAAJTAAR3cREwExMBdTU3F3d3d3d3F3Fzc3d3N3c3d1N3Nxc1MlIWU3YWRGQmVwBAAAAAAAAAQEAEAHZ3QABEAAB3dQB1AAAAAAAAAAABc0d2Z3d0ZWQQAAAABAAwBlJRNTB1MwMXBzd3d3V3d3d3d3dzd3d3d3N3d1N1cDU1MTQxcTcxNTMAAEZEAAAARAAAAAAFN3AAAAAAAHc0MQAAAAAAAAAAAAQTV3d3VnYXYABwAAAAQEQhMFIVMRU1M3E1d3c3dzdzd3V3d3dXN1d3d3c1MhNQMWFhcWNSFlclcAAAZwAGAEJAAAAAUnNxAAAAAAAAdXcAAAAAAAAAAABTERd3dmVEdAUkQAAAAEADFQExMDByE1NTdzd3V3dXd1Nzdxdzd3d3d3d3cDU0M0MTEwMQMXExczcTAQAABWcAAgAAADF1YAAAAAAAAAAHd3EBIQAQEQETERcTM3VGZ0dGVwcEcAAHFQIWEBFTFTQ1NRd1N3Nzc1N3dzd3d3d3dzdTdxNQM1MXBxcXNWE0MQUwcDBSU3AEcBQWFxdDNwAAAAAAAAAAAAAQEBF3AAAAZAJzc3N2dFZGd3d3d3MGV3NRATc0NTExcHNzd3N3V3d3N3dXc3VzVzdXd3c0M3U3c3NnMHExY1JzFxcXMTcAAAdzc1JxNXQAAAAAAAAAAAAAAABGQAAAAEZzNzc3NEZkd3d3d3d0AAc3NzcRAxA0NTcXF3NWU3NTdXcXc3Vzd3d3d3d3M1NzdxcXU1dyd1NxcWNzc1d3AAAHFzU3FndwAAAAAAAAAAAAAAAABGAAQARnYXNzc3R0V3d3d3d3cARjFxMRIDEhMTExczcXdzd3d3c3d3d3d3d3d3d3d3U3dzd3c3c3Fxc1N3NXF0dzc3dhd3Fnd3NXAAAAAAAAAAAAAAAABABAAAAABAYzczNGRnN3d3d3d3QAdzM3MxEAEBMTUxcXdzd3U3c3d3d3d3d3d3d3d3dzd3dXN3c3d3dzZ3F3N3NxZxdTU0M3NSV3NwAAAAAAAAAAAAAAAAAAAAAAAAADczc3RDM3N3d3d3dwAAd0ABAxMTMXMTczc1d1N3d3d3d3d3d3d3d3d3d3dzdzd3U3Vzc3Nxc2cXFlNzVyc2c3R1NzcXQAAAAAAAAAAAAARgAAAAAAAAAAA3NzNkN3M3N3d3d3dAQHMAAAAAABITczFzc3d3d3d3d3d3d3d3d3d3d3d3dXd3Nzd3N1dXVzUxcnM1NTF1dTVzc3dXYwAAAAAAAAAAAABCRAAAAAQAAEAAc3M3VzMzczM3d3d3AABwAAAAAAAAAAAHBHd3d3d3d3d3d3d3d3d3d3d3dzd3N1d1N1c3Nzd3d3U1cnNnM3N3NTVzc1cAAAAAAAAAAAAARAYAAAAABAQAQDczczN3Nzdzc3d3dwBAAAAAAAAAQAZAQEN3d3d3N1d3d3d3d3d3d3d3d3d3N3Nzd3N3d3dxc3Fzc1cXF1JXNHNyF3c0AAAAAAAAAAAAAAZEZAAAAAAAQAQzczczM3Mzczczd3cQAARwU0AQABZQN3d0dxdxd1d3d3d3d3d3d3d3d3d3N1d1d3NXcXNXd3V3dXc3d3N3c3N1d3cXdwAAAAAABmAABkAEdnQAAAAAQAAANzczc3M3czc3Nzd3QEAHd2AAQAAAAEQARzd3d3d3d3d3d3d3d3d3d3d3d3N3N3NXc3d3c3c3c3c3dTcXdTV1c3NTdxAAAAAAAAQEAARkBgRgAAAAAABAAHNzNzczczNzc3N3dwAAAEdHdCAAAAAABDV3d3d3d3d3d3d3d3d3d3d3d3d1d3d3d3d3d3d3d3d3d3d3dzdzc3dXd3cAAAAAAARgAABGAGRgAAAAQAAAAAA3M3Mzczc3Nzc3N3dgAAAAAABVAENhd3d3d3d3d3d3d3d3d3d3d3d3d3d3N3d3d3N3d3d3d3d3d3d3d3d3d3dzdzd3cAAAAAAAAAAAAABAZAAAAAQEAAAAM3M3Nzczc3Nzc3N3AEAAAAAAJ3c1d3d3d3d3d3d3d3d3d3d3d3d3d3V3d3d3d3N3dXNxd3V3d3dXc3d3d3d3d3d1c0BAAAAAAAAAAEAAQGQAAAAAAAAAAHM3M3MzczM3Nzc3d1AAAAAAAFd3d3d3d3d3d3d3d3d3d3cXd3VzdXdzd3d3dzV3d3N3d3N3N3U3c3dzVzVzU3VzdzcAAAAAAAAAAERgBAYGAAAAAAAAAEYzczczc3N3c3NzN3cAdGAAAAA3d3d3d3d3d3d3d3d3d3d3dzdzd3c3d3c3d3dzc3F3U1N1N1N3d3d3d3d3d3dzdxd1AAAAAAAAAAAAAABERARABAAAAAAGNzNzczczMzc3M3d3QGdAAAAAB3d3d3d3d3d3d3d3c3V3N3d1d3cXcXc3dzV3d3d3c3d3d3d3d3d3d3d3d3d3d3d3dwQAAAAAAAAAAAAAYABmYGYAAAAARDNzMzczc3czM3d3dwBnYAQARAd3d3d3d3d3d3d3d3d3d1c1c3U3d3d3V3dzd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3IBAAAAAAAAAAAAAEAARAREAAAAAAA3Nzczczczc3d3d3dwRgBnRmAHd3d3d3d3d3d3d3d3dzd3d3d3d3N3N3N3d3d3d3d3c3c3d3dzd3d1N3d3d3d3d3d1AEAAAAAAAAAAAAAABGBGAAAAAABGNzNzNzNzNzd3d3d3AEdGQGcAB3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3FzcXd3d1c3c3d1N3d3d3dzd1d3NzcAAAAAAAAAAAAABkRkAABGAAAAAAAHM3NzNzNzN3d3d3N1BmB2BAABd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3N3N3c1cXN3U3dzVzd3c3d1d3ckAAAAAAAAAAAABgZAAAAAAAAAAAA3M3N3NzN3d3d3dzdgR0ZABAYFd3d3d3d3d3d3d3d3d3d3d3d3d3d3V3V3FzNzU3d1cXcXVzd1NzdTd3d1d3d3d3d1AQAAAAAAAAAAAEZUAAAAAAAAAAAAczczMzN3d3d3d3F3EGYGdnR2dnd3d3d3d3d3d3d3d3d3d3c3d3d3c3dzd3d3VzdXNzdzY3Nxc3V3N3c3Nzc3d3c3EgBAAAAAAAAAAAAEYAAAAAAAAAAAAHNzc3N3d3d3d3dzdwBlZHZGRhd3d3d3d3d3d3d3d3d3V1d3d3dXV1dzV3NzU3Fzc1dzdXU1djVzNXc3dXd3d3N3d3UAAEAAAAAAAABEBkYAAEAAAAAAAABzNzM3d3d3d3d3cTcQZgZHZAAHd3d3d3d3d3V3d1c1d3d3d1dXc3c3V3d3Vzd3dXdzVzc3c3FzV3N1cHNzcXV3d3c3AAAAAAAAAAAEZ2RlZUZAAAAAAAAAdzNzd3dTd3d3d3d3RHRAdGcAUHd3d3d3d3V3d1c3dzVzdxdzc3d3dzd3c3F3Nzc3N3NXdTU3NDcHNzd1dXdzc1N3dwBQAAAAAAAARnZHQmZkAAAAAAAAAEczN3cHR0d3d3d3d3ZWdkJ2YCd3d1dTd3V3c3FzV3d3dXd3d3dXd3d3U3d3d3dXdXd3dzd3dXdzd1d1c3Nzd3d3V3cAAABAAAAAAGdAdgQEAAAAAAAAAAAHd3cQNxYXN3d3dzdnZmVkZHBXd1c3d3V3c3V3d3cXc3d3d3d3c1c1d3d3Nzd3d3c3FzVzd3NzV1Nzc3d3d3NXc3c3AAQAAAAAAABmZCRgQEAAAAAAAAAAB3d3cAdndHd3d3d2dnZ2dHQANXd3d3d3N3d3d3d3d3d3N3NXN3c3d3N3d3dXd3N3d3d3d3F3V3N3d1c1N1NXc1d3d3ABAAAAAAAEBAZAQAAkQAAAAAAAAAB3c3AUFHdWd3d3d2JHZ2dmAGd3d3d3N3d3dzd3N3d1N3d3d3d3d3d3d3d3d3N3d3d3c3U2c3c3U1c2d2d2dzdnNHcUAkAAAAAAAABEZAAARmAAAEAAAAAAdzdSAHd3J1d3d3AEAEdmd2cXd3d1d3d3d3d3dXdzd3d1d3dxd1Nxdxd3d3d1d1NTU1d3d3V3V3d3dTV1NzV1cXc1cAUAQAAAAAAAAAAEBABHZEBGQAAAAAd3NAFhZXV3d3cAZEAAR2QlZ3c3c3V3U3VzVzd3d3dzdzdzd3N3d3d3d3N3d3d3d3d3F3F3d3d3d3d3N3V3c3dXd3MAAAAEAAAAAABAAAAAAAAGdAAAAAAHd3FCV3c2d3dwBAAGAAZ2U3d3c3d3c3dzd3d3dzVzV3d3d3d3d3d3d3d1d3d3d3d3d3d3d3d3d3d3d3d3c3c3c1N3AHAEAAAAAAAABAAABAQAAEAAAAAAAHd3BSV2V3d3cAQAQEBEAGV3N3Vxc3d3d3c3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Nzc3F3U3d3N3VldSd3dQAAQAAAAAAAAAAABEJCRAAGQAAAAAB3dyQHdXZ3dwBABgAAcAA3N1c3N3V3U3U3Vzd3d3d3d3d3d3d3d3d3d3d3d3dzd3c3c3NXdXV3d3dXNXU3NzN3FzcwBwAAQAAAAAAAAARkZEAABnJEAAAAB3dQdWdld3UABEQEBkQEd3c3d3d3N3d3d3d1d3d3d3d3d3d3d3d3d3d3d1c3d3F3c3V3Nzc3Nzc3N3M3d1NXU3dXdAAAQAAAAAAAAAAABAAAAEBEBkAAAAR3dAd1d3dwBAQkYERgQ3V3d1dzd3d3d3d3d3d3d3N3d3d3d3d3d3d3d3c3d3V3NXVzcXVxcXVxdXF1clM3JzQ3J3MAcAAEAAAAAAAAAAAAAARgBGQAAAAAd3JSVnd3cARwQGQkASQ3N3c3dXd3d3d3d3d3N3N3d3dXNXd3d3d3d1c3dzc3N3c3N3dzc2c2Nyc3NzU1YXFzcXcXUABAAABAAAAAAAAAAARgAABAAAAAAEdxBHd3dwBnYAZWRkBXd3d3d3d3d3d3dzd3N3d3dXcXd3d3d3d3d3c3dzV3V3U3d1cXNxdTU1cXQ1JTdzc3NxdxdzAHAEAAAAAAAAAAAAAEAEYAAAAAAAAHd3dxE1cEdgBEZQAHJ3d3d3dzd3d3c3d3d3dXNXN3d3d3d3d3d3d3dzd3c3c3cXc3d1d3N3c3dzd3c0NXQ1Z3NzdxAGAEBABAAAAAAAAAAABAAAAAAAAAB3FXFxU1Z3BEYAJHB1d3V3N3d3c3d1dzVzV3N3d3d3d3d3d3d3d3dzV3c3d3d3d3d3dzdXNXcXdTU1d3N3c3F0dSdxAWAAAAAEAAAAAAAAAAYAAAAAAAAAd3E1N3d2dgAFZEAEJzU3N3U3c3V3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d1c3d3N3c3dzd3dzV3dTdXc3NxdwAQQAQAAAAAAAAAAABEAAAAAAAAAHcXE1d3dnQAYGQhQ1dXd3Vzd1d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3d3d3d3d3d3d3d3d3d3d3dzd3c3N3dzdXd3cwBCQABAAAAAAAAAAAAAAAAAAAAAB3cXR3d1Z2VAQFFCU3NzVzd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3d3dXd3d3d3d3d3c3V3dzd3c1N3cQAQBAAEBAAAAAAAAAAAAAAAAAAAdxcTdXd2R2dAQGF3d3d3d3dzdzd3d3d3d3d3c3d3d3dzdTd3d3d3d3d3dXd3d3d3N3N3dzd3U3cXdXdzc1N1Nzd3BzcQBABAAAAAAAAAAAAAAAAAAAAAAHdxcXd3dGd2ADAGU3dXd3d3d3d3d3d3d3c3d3d3d3d3d3d3d3d3d3d3c3NzU3F3d3V3cXd1N3d3dzdxd1d3U3V1NXNTYQAFAEBAQEAAAAAAAAAAAAAAAAB3FxcXdyB2cAAENzdzdzdzd1dzd3N3N3d3d3d3d3d3d3d3d3d3d3d3dXd3d3d3dzd3N3d3d3d3d3d3d3N3Nzdzc3c1d1MAAAQgAAAAQEAAAAAAAAAAAAAEd3NTd3dQQAQQQ3V3dXN1d3c3F3d3d3d3N3d3d3d3d3d3d3d3d3d3c3N3d3d3d3d3d3d3d3d3d3d3d3d3d1d3d3c3c3N3cgBQQEBAQAAABAAAAAAAAAAAAHcVNXd3AAABYHU3U3N3dzcXd3dxdxd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3U3NXcXdXNTUwAQAEAQQAQAAEBAAEAEAAQAAXc1NXd3AHAAcnc3d3dTd3d1N1d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d1d3d3d3N3dXd3d3U3dTdydXY3dxclJzQSAFAEBABAQEAAAEAAAABAAAdzU1N3cAUAZTU1d3dzd3F3N3c3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Vzd3c3d3dxc3d3d3d3N3d3d3d1N1NzV1J3F3UXNQAAcAAEAAAAQAQABABAAABHdxcXd3UAQ1N3dzc3d3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Nzd1c3cXNxd3d3NXdzd3d3N3d3N3N3d3N3F3MTY0NwAABWEEBAUAQABABAAEBAB3Uxd3dwA2d3FzdXdTd1d3d3d3d3d3d3d3d3c3d3d3d3d3d3d3d3d3V1dxd3d3d3dzcXdXc3d3d3V3d3N3c1Nxd3N3F3ZTU1NxYAAEcABAQAQABQAFABAAFzVxd3d2Fxd3dXN3d3d3d3d3d3d3d3d3d1c3V3d3d3d3d3d3d3d3Nzdzd3N1N3cXdXdzd3dTdTdzd3d1d3d3d3F1c3JTdzcnFxcQAAUlIAQAQEBgQAQEAHdTFxd3cXd3d3d3d3dzd3d3d3V3d3d3d3d3d3d3d3d3d3d3d3d3d1dxd1N1d3U3dzdzd3N3d3d3d3d3d3cXcXN3dzd1N3B3U2N3QyAABBZSQQAABABAAAR3Nxd3d3d3dzd3d3d3d3d3c3c3d3d3d3d3d3d3d3d3d3d3d3d3d3dzd3N3d3N3d3d3dXd1c3c3d3d3c3c3d3d1Nzd1N3F3U3V1c3dXdgAAAQYUFBAUNAUAd1dTd3d3d3d3c3dzd3d3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d1N3dzd3d3d3d3dzd3d3d3d3d3d3d3c3d3dXN3d3c3c3N3U3NzU3MAAAAABAABAAAHc3dxd3dzd3d1d1dXF3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3dzd3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3dzd3V3d3c3d3V3d3d3cWFhIWFjd3d3cQF3d3d3F3F3N3d3d3d3d3d3d3d3d3d3d3d3d3d3cXdXc3dXd1d3d3d3d3d3d3d3d3d3d3d3dzd3d3d3d3dzdzd3V3Nzdxdxd3FzdzdTd3d3d3d3d3d3VxcXd3d3F3d3d3c3d3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3c3d3c3d3d3d3c3dXcXdTd3d3c3N1dzdzdzU3dzVzdzc3dzd3V3N3c3dxcXd3d3dzd3d3d3d3d3d3c3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c1dTdTd3dXd3N3V1NXNXdXdTc3dzd1N1c1d1c1dXF1N3cXFzVzV3U1dTdzdXF3d3FxdXd3d3d3c3V3c3VzU3c3d3U3d3d3d3d3d3d3d3d3d3d3d3d3d3d3dzd3d3F3N1N1c3c3d3dzd3d3d3d3N3c3dzdzdzc3c3U3d3dzdXNTdzd1N3N3d3d3cXd3d3d3V3Vzd1dzd3d3d1c3d3d3d3d3d3d3d3d3d3d3d3d3d3c1d3d3d3d3d3d3d3d3d3d3d3N3d3d3d3d3d3d3d3d3d3d3dTdxd3N3d3d3d3dXd3dxdxFzd3cXNzc3d3c3d3d3cXc3d3d3d3d3d3d3d3d3d3d3d3d3d3d3dzc3d3d3d3d3d3d3d3d3N3d3d3dzd3V3d3d3d1d3d3U3Nzd3d3N3c3c3dTdzd3d3dxAQFBd3d1d1c3d3d3FzU3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3d3d3c3c3d3d3d3d3V3V3V3Vzd3dxdxc3FzU3dXVzU3N1cXU2Vzd3d3Nzd3d3d3Nhc3c3N3Vzd3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3c3d1cXdXNzd3dXd3NXU3NXNzdzd3d3N3Nzd3d3d3d3dzc3N3cXUzdjcXNXNTd3dXdxd3d1N3V3d3U3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Nzd3N3dXNXN1N3dzd3d3d3d3N3N3dXdXdzc1Nxc1NXcXUhdDd1NXc3c3d3Fzc3N3N3c3U3c3U3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d1cVNHF3Nzc3N3N3Fzd3Fzc3d3d3d3d3N3dzdXd3d3d3c3dzdzNxc3NxcXdzd3d3dXd3c3U3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3Nzd3N3F1dXdXNXc3dxd3dXVxc3d3d3d3c3d3Nxc1Nxc1cXVxdXdxd1N3cXV3N3NTd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d1NHNTU3c3Nxc1NxcXFzU3Nzd3d3d3d3d3dzd3d3d3d3dzdzdzc1NzU3Fzdzd3c3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3N3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3NTUAAAAAAAAAAAAAAQUAAAAAAADHrQX+"
            },
            "Supplier": {
                "SupplierID": 1,
                "CompanyName": "Exotic Liquids",
                "ContactName": "Charlotte Cooper",
                "ContactTitle": "Purchasing Manager",
                "Address": "49 Gilbert St.",
                "City": "London",
                "Region": null,
                "PostalCode": "EC1 4SD",
                "Country": "UK",
                "Phone": "(171) 555-2222",
                "Fax": null,
                "HomePage": null
            },
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },

        ...

````
`Category`と`Supplier`のデータも同時に取得できたことがわかります。	  しかし、すべてのEntityTypeの値を取得しているため不要な値が含まれています。特に`Category`の`Picture`のデータ量は無視できません。

このようなデータの取捨選択を行うためにはどうすればよいのでしょうか？そう`$select`を使うべきです。  
`$select`はEntityTypeに関連するEntityTypeについても有効です。`Category`と`Supplier`の双方について名称のみ取得するようにしましょう。URLパラメータに`$select=Category/CategoryName, Supplier/CompanyName`を追加します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$expand=Category, Supplier&$select=Category/CategoryName, Supplier/CompanyName>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products&$select=Category/CategoryName,%20Supplier/CompanyName",
    "value": [
        {
            "Category": {
                "CategoryName": "Beverages"
            },
            "Supplier": {
                "CompanyName": "Exotic Liquids"
            }
        },
        {
            "Category": {
                "CategoryName": "Beverages"
            },
            "Supplier": {
                "CompanyName": "Exotic Liquids"
            }
        },

        ...

````
今度は取得データを削りすぎてしまったようです。Category/CategoryName, Supplier/CompanyNameのみとなってしましました。元あったProductEnityTypeを含めるためには`*`という特殊なエイリアスを`$select`のパラメータに含める必要があります。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products?$format=json&$expand=Category, Supplier&$select=*, Category/CategoryName, Supplier/CompanyName>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products&$select=*,%20Category/CategoryName,%20Supplier/CompanyName",
    "value": [
        {
            "Category": {
                "CategoryName": "Beverages"
            },
            "Supplier": {
                "CompanyName": "Exotic Liquids"
            },
            "ProductID": 1,
            "ProductName": "Chai",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "10 boxes x 20 bags",
            "UnitPrice": "18.0000",
            "UnitsInStock": 39,
            "UnitsOnOrder": 0,
            "ReorderLevel": 10,
            "Discontinued": false
        },
        {
            "Category": {
                "CategoryName": "Beverages"
            },
            "Supplier": {
                "CompanyName": "Exotic Liquids"
            },
            "ProductID": 2,
            "ProductName": "Chang",
            "SupplierID": 1,
            "CategoryID": 1,
            "QuantityPerUnit": "24 - 12 oz bottles",
            "UnitPrice": "19.0000",
            "UnitsInStock": 17,
            "UnitsOnOrder": 40,
            "ReorderLevel": 25,
            "Discontinued": false
        },

        ...

````
これで望みのデータを取得することができました。

## Entityアクセス
今まではリストに対するデータアクセスでしたが、ここからは単一のEntityに対する操作です。

### key
ODataServiceが外部に公開するI/FはEntitySetであり、これにアクセスするとリストが返されます。1つのデータにアクセスするために最も効率の良い方法はEntitiesに対してEntityTypeの`key`を指定してアクセスする方法です。
URL上でEntitiesのkeyを表現するためには、Entities名の後ろにkeyを`(`と`)`で囲んで指定します。EntityTypeでどのプロパティがkeyとなるかはmetadataにて確認できます。  
では、`Products`のkeyは`ProductID`となっているので、2に該当するデータを取得します。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products(2)?$format=json>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products/@Element",
    "ProductID": 2,
    "ProductName": "Chang",
    "SupplierID": 1,
    "CategoryID": 1,
    "QuantityPerUnit": "24 - 12 oz bottles",
    "UnitPrice": "19.0000",
    "UnitsInStock": 17,
    "UnitsOnOrder": 40,
    "ReorderLevel": 25,
    "Discontinued": false
}
````

では、`Category`の名称も同時に取得してみましょう。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products(2)?$format=json&$expand=Category&$select=*, Category/CategoryName>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Products/@Element&$select=*,%20Category/CategoryName",
    "Category": {
        "CategoryName": "Beverages"
    },
    "ProductID": 2,
    "ProductName": "Chang",
    "SupplierID": 1,
    "CategoryID": 1,
    "QuantityPerUnit": "24 - 12 oz bottles",
    "UnitPrice": "19.0000",
    "UnitsInStock": 17,
    "UnitsOnOrder": 40,
    "ReorderLevel": 25,
    "Discontinued": false
}
````

では、Entityの中の一つのプロパティにアクセスしましょう。URLのEntities名の後ろにプロパティ名を指定します。  
`ProductName`にアクセスしてみます。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products(2)/ProductName?$format=json>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Edm.String",
    "value": "Chang"
}
````
このように、ODataの中ではEntitiesアクセスした際に取得したデータのプロパティを`/`で連結する事で、ダイレクトにプロパティへアクセスすることが可能です。  
先ほどは$expand指定していた`Category`もプロパティとしてアクセスすることが可能です。  
<http://services.odata.org/V3/Northwind/Northwind.svc/Products(2)/Category?$format=json>

結果は以下の通りです。
````js
{
    "odata.metadata": "http://services.odata.org/V3/Northwind/Northwind.svc/$metadata#Categories/@Element",
    "CategoryID": 1,
    "CategoryName": "Beverages",
    "Description": "Soft drinks, coffees, teas, beers, and ales",
    "Picture": "FRwvAAIAAAANAA4AFAAhAP////9CaXRtYXAgSW1hZ2UAUGFpbnQuUGljdHVyZQABBQAAAgAAAAcAAABQQnJ1c2gAAAAAAAAAAACgKQAAQk2YKQAAAAAAAFYAAAAoAAAArAAAAHgAAAABAAQAAAAAAAAAAACICwAAiAsAAAgAAAAIAAAA////AAD//wD/AP8AAAD/AP//AAAA/wAA/wAAAAAAAAAAABAAAAAAEAAAAAEAEAAAAAAAAAEBAQABAAAQAQAAAAEBAAEAAAAQAQAAAQAAABAQEAAQAAAQABAAAAAAAAAAAAAAEAAAAAEAAAAAAAAAEAAAAAAAAAAAAAAAEAEAEAAAAAAAAAAAAAEAEAEAABJQ..."
}
````

このように、URLパラメータを介してODataServiceを操作することができます。  
これまでの話はバックエンドのODataServiceに関するものでしたが、実際にODataserviceを利用してWebシステムを構築するためには、対となるフロントエンドのライブラリが必要です。  
以降は、標準でODataをサポートしているOpenUI5を利用して、実際にODataServiceを利用したWebシステムを構築していきます。


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

<a name="productlist_impl">5.3 商品リストの実装</a>
========

## <a name="productlist">5.3.a 商品リストの取得</a>
では、実際に商品リストを取得してTable上に表示させてみましょう。`view/SearchList.fragment.coffee`を開いてください。`view/SearchList.fragment.coffee`は商品リストテーブルのUI部分を切り出したUI部品です。商品リストテーブルUIに関連する変更はこちらに記述していきます。

まず、`view/SearchList.fragment.coffee`の`createContent`にて利用するODataServiceのEntitiesを指定します。このUIとODataを関連づける作業を**データバインド**と呼びます。

*view/SearchList.fragment.coffee:createContent()*
```coffeescript
	
	...

  createContent: (oController) ->
    new sap.m.Table
      id: oController.getView().createId("productList")
      growing: true
      growingThreshold: 5
      growingTriggerText: "もっと見る"
      noDataText: "データがありません。"
      headerToolbar: @_createHeaderToolbar(oController)
      columns: @_createHeaderColumns(oController)
      # ここにODataをバインドしていきます。
      items:
        path: "/Products"
        template: @_createTemplate(oController)

    ...

```
`items`プロパティにデータバインドを定義していきます。`path`には利用するEntitiesを、`template`には1行を生成するためのテンプレート定義を設定します。

結果は以下の通りです。
![itemsにデータバインドのみ](docs/img/5.3.a-1.png)

結果は48件表示されると思いますが、列の中身はすべて同じです。  
これはテンプレートの中身が固定値であるためです。次は、実際にテンプレートをODataの内容にあわせて表示させてみましょう。今度は`view/SearchList.fragment.coffee`の`_createTemplate`を変更します。

*view/SearchList.fragment.coffee:_createTemplate()*
```coffeescript
  _createTemplate: (oController) ->
    new sap.m.ColumnListItem
      type: "Navigation"
      press: [oController.onItemPress, oController]
      cells: [
        new sap.m.Text
          text: "{Supplier/CompanyName}"
        new sap.m.Text
          text: "{Category/CategoryName}"
        new sap.m.ObjectIdentifier
          title: "{ProductName}"
          text: "{QuantityPerUnit}"
        new sap.m.ObjectNumber
          number: "{UnitsOnOrder}"
        new sap.m.ObjectNumber
          number: "{UnitsInStock}"
        new sap.m.ObjectNumber
          number: "{UnitPrice}"
          unit: "USD"
      ]
```
テンプレート定義は`sap.m.ColumnListItem`を作成して返します。  
`cells`の中に各セルとなるUIコントロールが定義されている構造が読み取れると思います。各UIコントロールの中の`{`から`}`の中に含まれている文字列が**path**よ呼ばれるもので、ODataのEntitiesからの相対的な位置を指定して各UIコントロールに対してピンポイントでデータバインドを定義しています。  
プロパティからさらに子のプロパティを参照する場合の区切り文字は`/`を指定します。まるで、windwosのフォルダの`¥`指定のようですね。

結果は以下の通りです。
![templateもデータバインドのみ](docs/img/5.3.a-2.png)

`Product`の内容は表示することができましたが、`Supplier`と`Category`の内容が表示されません。これはODataのデータ取得の際に、返却されるデータにこれらの関連するAssociationのデータが含まれていないためです。

返却されくるデータに関連するAssociationのデータを含めるためには、`$expand`と`$select`を利用します。これらをOpenUI5で扱うためには、先ほどの取り上げた商品リストテーブルUIのデータバインドする際に、パラメータを渡すように設定します。  
`view/SearchList.fragment.coffee`の`createContent`のデータバインド部分を変更します。

*view/SearchList.fragment.coffee:createContent()*
```coffeescript
	
	...

  createContent: (oController) ->
    new sap.m.Table
      id: oController.getView().createId("productList")
      growing: true
      growingThreshold: 5
      growingTriggerText: "もっと見る"
      noDataText: "データがありません。"
      headerToolbar: @_createHeaderToolbar(oController)
      columns: @_createHeaderColumns(oController)
      # ここにODataをバインドしていきます。
      items:
        path: "/Products"
        template: @_createTemplate(oController)
        parameters:
          expand: "Category, Supplier"
          select: "*, Category/CategoryName, Supplier/CompanyName"

    ...

```
データバインドする際のプロパティに`parameters`を含める事で、ODataでデータアクセスするさいにパラメータを渡すことができるようになります。

結果は以下の通りです。
![商品リスト](docs/img/5.3.a-3.png)

これで一通りODataのEntitiesをテーブルにデータバインドして表示することができました。

## <a name="search">5.3.b 商品名での検索</a>

では、次に商品名での検索機能を作っていきましょう。  
ODataSeviceのEntitiesに対して何らかのFilter処理を施す場合は、`$filter`を利用します。  
`view/Master.controller.coffee`の`onSearch`に検索処理を実装していきます。

*view/Master.controller.coffee:onSearch()*
```coffeescript
  
  ...

  onSearch: (evt) ->
    # ここに検索処理を書きます。

    # 画面からの入力値を受け取ってfilter定義を作成
    query = @query.getValue()
    filters = [new sap.ui.model.Filter("ProductName", "Contains", query)]
    
    # 商品リストテーブルUIのデータバインド定義を取得してfilter設定
    binding = @productList.getBinding "items"
    binding.filter filters, sap.ui.model.FilterType.Application

    ...

```
filterの演算子は`sap.ui.model.FilterOperator`に定義されているものを利用します。今回はあいまい検索の想定で`Contains`を指定しています。それ以外の設定値は以下の通りです。

```js
{
  BT: "BT"
  Contains: "Contains"
  EQ: "EQ"
  EndsWith: "EndsWith"
  GE: "GE"
  GT: "GT"
  LE: "LE"
  LT: "LT"
  NE: "NE"
  StartsWith: "StartsWith"
}
```

ちなみに、filter定義の`filters`はArrayであるため、複数のfilter定義を含めることが出来ます。

では、商品名の部分に`Cha`を入力して検索してみましょう。  
結果は以下の通りです。
![商品名検索](docs/docs/img/5.3.b-1.png)

このままでもいいのですが、検索時などのODataServiceへのデータアクセスの際にユーザーに対してフィードバックがありませんので、データアクセス時にローディングイメージを表示するようにしましょう。OpeUI5ではODataServiceはODataModelとして取り扱います。ODataModelにはODataServiceへのデータアクセスに関連するライフサイクルイベントが利用できますので、今回はライフサイクルイベントを利用してローディングイメージを表示させてみましょう。  
`Componemt.coffee`の`init`を変更しましょう。  

*Componemt.coffee:init()*
```coffeescript

  init: ->

    ...

    # ここにOdataServiceのエンドポイントを設定します
    # /V3/Northwind/Northwind.svc/
    endpoint = sap.ui.model.odata.ODataModel "/V3/Northwind/Northwind.svc/", true
    @setModel endpoint

    # バックエンドにデータ問い合わせの際のローディングイメージを表示します。
    busy = new sap.m.BusyDialog
      title: "Loading data"
    endpoint.attachRequestSent ->　busy.open()
    endpoint.attachRequestCompleted ->　busy.close()

    ...

```
`new sap.m.BusyDialog`でローディングイメージを表示するダイアログを生成します。上で作成したODataModeオブジェクトに対して`attachRequestSent`と`attachRequestCompleted`にてライフサイクルイベントが発生したタイミングで処理を割り込ませる事が可能です。  
`attachRequestSent`はODataServiceに対するデータアクセスが開始されたタイミングで発生します。
`attachRequestCompleted`はデータアクセスが完了したタイミングで発生します。成功、失敗は問いません。

先ほどと同じ商品名の部分に`Cha`を入力して検索してみましょう。  
結果は以下の通りです。
![商品名検索ローディングあり](docs/docs/img/5.3.b-2.png)

実際には、ローディング開始のタイミングが少し遅いと思いますので、ボタンを押したタイミングでローディングを表示させるなど、工夫が必要です。

ここまでで商品検索処理を実現することができました。

## <a name="sortandfilter">5.3.c 商品リストのソート、フィルタ</a>


## <a name="gotodetail">5.3.d 商品詳細への画面遷移</a> 

<a name="product_impl">5.4 商品詳細の実装</a>
========

## <a name="product">5.4.a 商品情報の参照</a>


## <a name="category">5.4.b カテゴリ情報の参照</a>


## <a name="supplier">5.4.c メーカー情報の参照</a>