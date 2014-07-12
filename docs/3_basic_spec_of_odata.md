3. ODataの構造
========

ODataはHTTPをベースに構成されているため、1つのバックエンドとのやり取りを見る限る通常のHTTPとなんら変わりはありません。  
バックエンドへの問い合わせは通常の`GET`、`POST`、`PUT`、`DELETE`で行い、返されるデータも`xml`、 `json`、`atom`形式です。  
しかし、ODataはバックエンドとの手続きと標準化しているため、HTTP上の手続きを統合するための上位概念を持っており、これを理解しない限りODataを理解することはできません。

この概念がMetadataと呼ばれる、ODataServiceが外部に公開するODataのデータモデルです。この章ではMetadataを見ながらのODataのデータモデルについて基本的なことを説明します。

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


## EntityConteinerとAssociationSet、EntitySet