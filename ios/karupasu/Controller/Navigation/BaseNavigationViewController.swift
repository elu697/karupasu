//
//  BaseNavigationViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxSwift
import UIKit
import Unio


/// ベースとなるナビゲーション
final class BaseNavigationViewController: UINavigationController {

    let viewStream: BaseNavigationViewStreamType = BaseNavigationViewStream()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.appMain,
                NSAttributedString.Key.font: UIFont.appFontBoldOfSize(16)
            ]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        super.viewDidLoad()
        self.isNavigationBarHidden = false
        self.navigationBar.barTintColor = .white
        self.navigationBar.backgroundColor = .white
        self.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.appMain,
            NSAttributedString.Key.font: UIFont.appFontBoldOfSize(16)
        ]
    }
}
