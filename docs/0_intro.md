OpenUI5とODataを使ってWebアプリケーションを作る
=========================
OpenUI5内部でOdataServiceをどのように統合すればよいか。

How to integrate OdataService in OpenUI5

![OpenUI5withOData](img/1.png)

# <a name="table">目次</a>

1. [はじめに](#intro)
1. [ODataとは何か？](#whatisOdata)
1. [ODataの構造](#basic)
1. [ODataServiceをURLで操作する](#manipulating)
1. [OpenUI5とODataServiceの統合](#openui5withodata)
	- 5.1. [導入](#install)  
	- 5.2. [プロジェクトの説明](#project)
	- 5.3. [商品リストの実装](#productlist_impl)
		* 5.3.a [商品リストの取得](#productlist)  
		* 5.3.b [商品名での検索](#search)  
		* 5.3.c [商品リストのソート、フィルタ](#sortandfilter)  
	- 5.4. [商品詳細の実装](#product_impl)
		* 5.4.a [商品情報の参照](#product)
		* 5.4.b [カテゴリー情報とメーカー情報の参照](#category)  
 	- 6. [まとめ](#summary)  

# <a name="intro">はじめに</a>