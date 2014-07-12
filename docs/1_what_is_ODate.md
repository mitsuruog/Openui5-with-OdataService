1. ODataとは何か？
========

> OData is a standardized protocol for creating and consuming data APIs. OData builds on core protocols like HTTP and commonly accepted methodologies like REST. The result is a uniform way to expose full-featured data APIs.  
<http://www.odata.org/> - Odata公式

> ODataとはデータAPIを作成し利用するために標準化されたプロトコルです。ODataはHTTPプロトコルと、一般的に浸透しているRESTという方法論で構成されています。つまり、これらのフル機能を満たすDataAPIを公開するために統一された方法です。
（意訳あり）

とOdata.orgの公式ではこのように謳っていますが、フロントエンドエンジニアの私から感じたODataとは、

「Webシステムにおける、フロントエンドとバックエンドとの面倒な問い合わせ手続きを標準化したプロトコル」

と言った印象です。

旧来、システムからRDBMSへのデータアクセスの方法を統一するために標準化された方法としてODBCが存在しますが、これと同様に、フロントエンドからバックエンドへのデータアクセスを統一化するために標準化された方法が「OData」と言えます。つまり、ODBCのWeb版です。  
特にODataにおいては、検索、ページングに代表されるデータの取得を行うときに、その標準化のメリットを感じる事が多いでしょう。

ODataに関する情報はこちらが公式サイトとなっています。  
<http://www.odata.org/>