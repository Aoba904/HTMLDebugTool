HTMLDebugTool
=============

・何ができるか
ローカルサーバー、ブラウザの自動更新、html/javascript/CSS圧縮


・同梱ファイル
app.bat
本体、起動するとサーバーが立ち上がる。

app.js
サーバーのスクリプト

setting.json
設定ファイル

html
プロジェクトフォルダ

node.scripts
あれこれ入ったフォルダ


・コマンド一覧
help  	(void)			コマンド一覧を見る。
build		(void)			html/javascript/cssを圧縮してbuildフォルダに出力する。


・設定プロパティ一覧
number 		port			開放ポート番号
number		host			サーバーのホスト名
<string>Array 	scripts			割り込ませたいスクリプト
