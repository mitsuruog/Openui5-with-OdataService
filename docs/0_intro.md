OpenUI5とODataを使ってWebアプリケーションを作る
=========================
OpenUI5とOdataServiceをWebアプリケーションとしてどのように統合すればよいか。

How to integrate OdataService in OpenUI5

![OpenUI5withOData](img/1.png)

# <a name="table">目次</a>

1. [はじめに](#intro)
1. [なぜODataが注目されるべきなのか？](#whatisOdata)
1. [ODataの基本](#basic)
1. [ODataServiceをURLで操作する](#manipulating)
1. [OpenUI5とODataServiceの統合](#openui5withodata)
	- 5.1. [導入・準備](#install)  
	- 5.2. [プロジェクトの説明](#project)
	- 5.3. [商品リストの実装](#productlist_impl)
		* 5.3.a [商品リストの取得](#productlist)  
		* 5.3.b [商品名での検索](#search)  
		* 5.3.c [商品リストのソート、フィルタ](#sortandfilter)  
	- 5.4. [商品詳細の実装](#product_impl)
		* 5.4.a [商品情報の参照](#product)
		* 5.4.b [カテゴリー情報とメーカー情報の参照](#category)  
1. [まとめ](#summary)  

# <a name="intro">1. はじめに</a>

このチュートリアルはOpenUI5とODataServiceを利用したWebアプリケーションを構築する上で、ODataをOpenUI5内でどのように扱えば良いかを中心に行います。  

特にODataが持つURLパラメータを組み合わせによる柔軟なデータアクセス方法と、OpenUI5というUIフレームワークを組み合わせた場合に実現できる、データアクセスからUIへのフィードバックがシームレスに統合され隠蔽された、これからの企業向けWebアプリケーション開発における「OpenUI5＋ODataService」という新しい可能性（選択肢）を感じてもらえればと思います。

このチュートリアルはODataV2をベースにしています。

Main thema this tutorial to build Web applications using the OpenUI5 and ODataService, OData, OpenUI5 in how to handle good.

From this obfuscated, and seamlessly integrate feedback UI from data access for enterprise Web application development can provide if you combine the UI framework by combining flexible data access methods and OpenUI5 especially with OData URL parameter "OpenUI 5 + ODataService" that would give me feel new possibilities (choices).

This tutorial is based on OData V2.
