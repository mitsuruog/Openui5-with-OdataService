<a name="basic">3. ODataの基本</a>
========

ODataはHTTPをベースに構成されているため、1つのバックエンドとのやり取りを見る限る通常のHTTPとなんら変わりはありません。  
バックエンドへの問い合わせは通常の`GET`、`POST`、`PUT`、`DELETE`で行い、返されるデータも`xml`、 `json`、`atom`形式です。

しかし、ODataはバックエンドとの間の複数のHTTP問い合わせを統合して標準化しています。そしてODataを返すバックエンドがODataServiceと呼ばれるものです。  
ODataServiceは、内部に「インターフェース層」「実体化層」「抽象化層」の3つで構成されています。フロントエンドがODataServiceにアクセスする際は、ODataのデータモデルを提供する「Metadata」か、実際のデータAPIインターフェース「EntityContainer」のどちらかを呼び出します。

こちらが、ODataServiceについての概念図です。  
![ODataService概念図](img/3-1.png)
（上の内容については、筆者の独自の解釈が含まれています。誤りがある可能性があります。）

ODataを理解する上では、特にデータモデルの構造を理解する事が重要です。まずMetadataを見ながらのODataのデータモデルについて基本的なことを理解しましょう。

今回のチュートリアルで利用するNorthwindのMetadataをベースに進めていきます。Metadataはこちらで確認できます。  

<http://services.odata.org/V2/Northwind/Northwind.svc/$metadata>

## EntityTypeとEntities

### EntityType

EntityTypeはODataを構成する最も小さなデータ構造体です。Northwindの`Category`と`Product`のEntityTypeを見てみます。

*Category*
````xml
<EntityType Name="Category">
	<Key>
		<PropertyRef Name="CategoryID"/>
	</Key>
	<Property xmlns:p8="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="CategoryID" Type="Edm.Int32" Nullable="false" p8:StoreGeneratedPattern="Identity"/>
	<Property Name="CategoryName" Type="Edm.String" Nullable="false" MaxLength="15" Unicode="true" FixedLength="false"/>
	<Property Name="Description" Type="Edm.String" Nullable="true" MaxLength="Max" Unicode="true" FixedLength="false"/>
	<Property Name="Picture" Type="Edm.Binary" Nullable="true" MaxLength="Max" FixedLength="false"/>
	<NavigationProperty Name="Products" Relationship="NorthwindModel.FK_Products_Categories" FromRole="Categories" ToRole="Products"/>
</EntityType>
````

*Product*
````xml
<EntityType Name="Product">
	<Key>
		<PropertyRef Name="ProductID"/>
	</Key>
	<Property xmlns:p8="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="ProductID" Type="Edm.Int32" Nullable="false" p8:StoreGeneratedPattern="Identity"/>
	<Property Name="ProductName" Type="Edm.String" Nullable="false" MaxLength="40" Unicode="true" FixedLength="false"/>
	<Property Name="SupplierID" Type="Edm.Int32" Nullable="true"/>
	<Property Name="CategoryID" Type="Edm.Int32" Nullable="true"/>
	<Property Name="QuantityPerUnit" Type="Edm.String" Nullable="true" MaxLength="20" Unicode="true" FixedLength="false"/>
	<Property Name="UnitPrice" Type="Edm.Decimal" Nullable="true" Precision="19" Scale="4"/>
	<Property Name="UnitsInStock" Type="Edm.Int16" Nullable="true"/>
	<Property Name="UnitsOnOrder" Type="Edm.Int16" Nullable="true"/>
	<Property Name="ReorderLevel" Type="Edm.Int16" Nullable="true"/>
	<Property Name="Discontinued" Type="Edm.Boolean" Nullable="false"/>
	<NavigationProperty Name="Category" Relationship="NorthwindModel.FK_Products_Categories" FromRole="Products" ToRole="Categories"/>
	<NavigationProperty Name="Order_Details" Relationship="NorthwindModel.FK_Order_Details_Products" FromRole="Products" ToRole="Order_Details"/>
	<NavigationProperty Name="Supplier" Relationship="NorthwindModel.FK_Products_Suppliers" FromRole="Products" ToRole="Suppliers"/>
</EntityType>
````
`EntityType`の中に`key`と`Property`が存在するような、良く見るデータ構造体です。  
`NavigationProperty`はこのEntityTypeが他のEntityTypeと関連がある場合の情報で、RDBMSの外部キーのようなものです。後述する`Association`とセットで利用されます。

### Entities

EntitiesはEntityTypeのデータ構造体を実際のデータにしたものです。 
Javaで置き換えるとクラスがEntityTypeで、Entitiesはそのインスタンスに該当します。そのため、Entitiesはリストになるケースが多いです。
以下が、`Product`のEntitiesの抜粋です。  
<http://services.odata.org/V2/Northwind/Northwind.svc/Products?$format=json>

````javascript
{
	"d": {
		"results": [{
				"__metadata": {
					"uri": "http://services.odata.org/V2/Northwind/Northwind.svc/Products(1)",
					"type": "NorthwindModel.Product"
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
				"Discontinued": false,
				"Category": {
					"__deferred": {
						"uri": "http://services.odata.org/V2/Northwind/Northwind.svc/Products(1)/Category"
					}
				},
				"Order_Details": {
					"__deferred": {
						"uri": "http://services.odata.org/V2/Northwind/Northwind.svc/Products(1)/Order_Details"
					}
				},
				"Supplier": {
					"__deferred": {
						"uri": "http://services.odata.org/V2/Northwind/Northwind.svc/Products(1)/Supplier"
					}
				}
			},

		...

````
注目は、問い合わせURLが`Product`ではなく`Products`となっているところです。こちらは、後述する`EntitySet`にて取り上げます。

## Association

### Association

2つ以上のEntityTypeの関連を定義したものです。RDBMSのスキーマ定義における外部キーに相当します。先ほどの2つのEntityType`Category`と`Entity`には関連がありますので、それを見てみましょう。

````xml
<Association Name="FK_Products_Categories">
	<End Role="Categories" Type="NorthwindModel.Category" Multiplicity="0..1"/>
	<End Role="Products" Type="NorthwindModel.Product" Multiplicity="*"/>
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

## EntityContainerとAssociationSet、EntitySet

### EntityContainer

ODataServiceが外部に公開するI/Fを納めたコンテナ定義です。  
上で挙げた`EntityType`や`Association`はODataService内部の定義であって、外部の利用者はEntityContainerにて公開されているI/Fを利用します。

### EntitySet

EntityTypeの外部公開I/F名。`Product`の場合、EntitySetの名前が`Products`となっているため、外部からアクセスする場合は`Products`を利用します。慣例でEntityTypeの複数系で、Entitiesを表すことが多いようです。

以下にEntityContainerとEntitySetを抜粋します。

````xml
<Schema xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns="http://schemas.microsoft.com/ado/2008/09/edm" Namespace="ODataWeb.Northwind.Model">
	<EntityContainer xmlns:p7="http://schemas.microsoft.com/ado/2009/02/edm/annotation" Name="NorthwindEntities" p7:LazyLoadingEnabled="true" m:IsDefaultEntityContainer="true">
		<EntitySet Name="Categories" EntityType="NorthwindModel.Category"/>
		<EntitySet Name="CustomerDemographics" EntityType="NorthwindModel.CustomerDemographic"/>
		<EntitySet Name="Customers" EntityType="NorthwindModel.Customer"/>
		<EntitySet Name="Employees" EntityType="NorthwindModel.Employee"/>
		<EntitySet Name="Order_Details" EntityType="NorthwindModel.Order_Detail"/>
		<EntitySet Name="Orders" EntityType="NorthwindModel.Order"/>
		<EntitySet Name="Products" EntityType="NorthwindModel.Product"/>

		...

	</EntityContainer>
</Schema>
````

### AssociationSet

EntitySetと同じくAssociationの外部公開I/F名。以下が`FK_Products_Categories`のAssociationSet定義です。AssociationSetもEntityContainer内部に格納されています。


````xml
<AssociationSet Name="FK_Products_Categories" Association="NorthwindModel.FK_Products_Categories">
	<End Role="Categories" EntitySet="Categories"/>
	<End Role="Products" EntitySet="Products"/>
</AssociationSet>
````

ODataを利用した実際の開発では、このようにODataServiceが提供するMetadataを参照しながら行っていきます。  
これまでのWeb開発での、RDBMSのスキーマ定義を参照しながら開発することと何ら変わりない事が理解できると思います。

**[[⬆]](#table)**