//
//  TabBarMenuViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxSwift
import UIKit
import Unio
import ESTabBarController_swift


/// 画面下部のタブメニュー
final class TabBarMenuViewController: ESTabBarController {
    let viewStream: TabBarMenuViewStreamType = TabBarMenuViewStream()
    let rootViewStream: RootViewStreamType

    let disposeBag = DisposeBag()

    private lazy var searchViewController = {
        return SearchViewController()
    }()

    private lazy var bookmarkTabViewController = {
        return BookmarkTabViewController()
    }()

    private lazy var dammyViewController = {
        return UIViewController()
    }()

    private lazy var chatViewController = {
        return ChatViewController()
    }()

    private lazy var accountViewController = {
        return AccountViewController()
    }()

    init(rootViewStream: RootViewStreamType) {
        self.rootViewStream = rootViewStream
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBar()
    }

    private func setTabBar() {
        tabBar.backgroundColor = .white
        tabBar.barStyle = .default
        tabBar.barTintColor = .white

        let v1 = searchViewController
        v1.tabBarItem = ESTabBarItem.init(TabBarItemView(),
                                          title: nil,
                                          image: AppImage.tab_icon_search_gray(),
                                          selectedImage: AppImage.tab_icon_search_blue(),
                                          tag: 1)
//        v1.title = ""

        let v2 = bookmarkTabViewController
        v2.tabBarItem = ESTabBarItem.init(TabBarItemView(),
                                          title: nil,
                                          image: AppImage.tab_icon_bookmark_gray(),
                                          selectedImage: AppImage.tab_icon_bookmark_blue(),
                                          tag: 2)
//        v2.title = ""

        // Dammmy
        let v3 = dammyViewController
        v3.view.backgroundColor = .white
        v3.tabBarItem = ESTabBarItem.init(TabBarCenterItemView(),
                                          title: nil,
                                          image: AppImage.tab_icon_create(),
                                          selectedImage: AppImage.tab_icon_create(),
                                          tag: 3)
//        v3.title = ""

        let v4 = chatViewController
        v4.tabBarItem = ESTabBarItem.init(TabBarItemView(),
                                          title: nil,
                                          image: AppImage.tab_icon_chat_gray(),
                                          selectedImage: AppImage.tab_icon_chat_blue(),
                                          tag: 4)
//        v4.title = ""

        let v5 = accountViewController
        v5.tabBarItem = ESTabBarItem.init(TabBarItemView(),
                                          title: nil,
                                          image: AppImage.tab_icon_account_gray(),
                                          selectedImage: AppImage.tab_icon_account_blue(),
                                          tag: 5)
//        v5.title = ""

        let n1 = BaseNavigationViewController(rootViewController: v1)
        let n2 = BaseNavigationViewController(rootViewController: v2)
        let n3 = BaseNavigationViewController(rootViewController: v3)
        let n4 = BaseNavigationViewController(rootViewController: v4)
        let n5 = BaseNavigationViewController(rootViewController: v5)

        self.viewControllers = [n1, n2, n3, n4, n5]

        self.shouldHijackHandler = { tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }

        self.didHijackHandler = { [weak self] tabbarController, viewController, index in
            // TabBarのchildにいるとModal表示ができないので,rootVCで表示
            self?.rootViewStream.input.eventCreate(())
        }
    }
}
