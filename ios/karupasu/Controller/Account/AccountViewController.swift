//
//  AccountViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxSwift
import UIKit
import Unio


/// アカウント管理
final class AccountViewController: UIViewController {

    let viewStream: AccountViewStreamType = AccountViewStream()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = AppText.account()
    }
}
