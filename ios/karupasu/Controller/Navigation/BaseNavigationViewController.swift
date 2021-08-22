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
        super.viewDidLoad()
        self.navigationBar.barTintColor = .white
        self.navigationBar.backgroundColor = .white
        self.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.appMain,
            NSAttributedString.Key.font: UIFont.appFontBoldOfSize(16)
        ]
    }
}
