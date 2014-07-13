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