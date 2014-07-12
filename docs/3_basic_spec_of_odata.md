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

EntitySetと同じくAssociationの外部公開I/F名。以下が`FK_Products_Categories`のAssociationSet定義です。


````xml
	<AssociationSet Name="FK_Products_Categories" Association="NorthwindModel.FK_Products_Categories">
		<End Role="Categories" EntitySet="Categories"/>
		<End Role="Products" EntitySet="Products"/>
	</AssociationSet>
````

ODataServiceを利用した実際の開発では、このようにODataServiceが提供するMetadataを参照しながら行っていきます。  
これまでのWeb開発での、RDBMSのスキーマ定義を参照しながら開発。というのと同じですね。
