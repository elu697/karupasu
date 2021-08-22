# チーム カルパス 「マッチマッチ」 iOS App
チームカルパスのiOSアプリリポジトリ

# 実行
1. ライブラリのインストール
 ```
 $ cd ios
 $ pod install 
 ```

2. ビルドと実行
 ※ Xcodeがインストール済の上で
 ```
 $ open karupasu.xcworkspace
 ```
 左上もしくはcmd + R で実行

# 構成等
- RxSwiftベース
- アーキテクチャ: MVVM (ViewStream conforming to the Unio)
  - Model: User等のModel自体と通信等の呼び出し処理
  - View: 画面構成
  - ViewController: ViewとViewStreamのbind
  - ViewStream: システムロジック
		
