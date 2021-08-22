//
//  BookmarkTabViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxSwift
import UIKit
import Unio
import XLPagerTabStrip



/// お気に入りと参加企画一覧のタブ表示
final class BookmarkTabViewController: ButtonBarPagerTabStripViewController {

    let viewStream: BookmarkTabViewStreamType = BookmarkTabViewStream()
    private let disposeBag = DisposeBag()

    private lazy var bookmarkCollectionViewController: BookmarkCollectionViewController = {
        let vc = BookmarkCollectionViewController()
        vc.title = AppText.favorite()
        return vc
    }()

    private lazy var appliedCollectionViewController: AppliedCollectionViewController = {
        let vc = AppliedCollectionViewController()
        vc.title = AppText.applying()
        return vc
    }()

    private lazy var bookmarkTabView: BookmarkTabView = {
        return BookmarkTabView(frame: view.frame)
    }()

    private lazy var barView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhiteGray
        return view
    }()


    override func viewDidLoad() {
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.navigationBar.backgroundColor = .white
//        edgesForExtendedLayout = .bottom
//        navigationController?.navigationBar.backgroundColor = .clear
//        navigationController?.navigationBar.isTranslucent = true
//        extendedLayoutIncludesOpaqueBars = true
        //バーの色
        settings.style.buttonBarBackgroundColor = .white
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = .white
        //セルの文字色
        settings.style.buttonBarItemTitleColor = .appMain
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = .appMain
        settings.style.buttonBarHeight = 44
        settings.style.selectedBarHeight = 2
        settings.style.selectedBarVerticalAlignment = .bottom

        settings.style.buttonBarItemFont = .appFontBoldOfSize(14)
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.titleView = buttonBarView
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [bookmarkCollectionViewController, appliedCollectionViewController]
    }
}
