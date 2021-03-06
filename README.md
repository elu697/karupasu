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
		
# ディレクトリ
```
ios
├── Pods #CocoaPodsからのライブラリ郡
├── karupasu #プロジェクトディレクトリ
│   ├── Assets.xcassets #アイコン等イメージセット
│   ├── Common #各所で使うクラス等をまとめたもの
│   ├── Controller #ViewControllerとViewStream(ViewModel)を格納したディレクトリ
│   │   ├── Account #アカウント設定画面(未実装)のロジック
│   │   ├── Bookmark #ブックマーク画面及び参加済み画面のロジック
│   │   ├── Chat #チャット画面のロジック
│   │   ├── Event #イベント関係全ての画面のロジック
│   │   ├── Login #ログイン周りの画面のロジック
│   │   ├── Menu #ブックマーク画面でのスワイプ可能のメニュー実装ロジック
│   │   ├── Navigation #基本となるナビゲーション
│   │   ├── Onboarding #アプリ紹介のオンボーディング実装
│   │   ├── Over #透過フルスクリーン画面の実装
│   │   ├── Root #一番下に来るViewControllerのロジック
│   │   ├── Search #イベント検索画面に関わるロジック
│   │   ├── Splash #アプリ起動時のロード画面のロジック
│   │   └── Team #チームに関する画面のロジック
│   ├── Extention #UIKit含むSwift標準クラスの拡張
│   ├── Library #外部ライブラリ
│   │   └── SemiModal #画面下部からのハーフモーダル機能
│   ├── Model #アプリ内で利用しているデータのモデルクラスセット(MVVMとしてのModel+Fluxを若干)
│   ├── Provider #Moyaを用いたネットワーク通信クラスセット
│   │   └── stub #スタブデータのjson
│   ├── Util #標準クラスの利用を容易にしたクラス
│   ├── View #Controllerで表示する画面自体のレイアウト実装(MVVMとしてのView)
│   │   ├── Bookmark #ブックマーク関係画面
│   │   ├── Chat #チャット関係画面
│   │   ├── Event #イベント関係画面とそのUIパーツ
│   │   ├── Filter #イベント絞り込み画面
│   │   ├── Login #ログイン画面
│   │   ├── Navigation #ナビゲーション画面
│   │   ├── Over #透過フルスクリーン画面
│   │   ├── TabVar #タブメニューで利用するUIパーツ
│   │   ├── Team #チーム画面
│   │   └── TextField #文字入力の基本UIパーツ
│   └── ja.lproj
├── karupasu.xcodeproj
└── karupasu.xcworkspace
```
