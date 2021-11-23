//
//  AccountViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxSwift
import UIKit
import Unio
import Eureka


/// アカウント管理
final class AccountViewController: FormViewController {

    let viewStream: AccountViewStreamType = AccountViewStream()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = AppText.account()
        setupForm()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        form.allRows.forEach { $0.reload() }
    }
}

extension AccountViewController {
    private func setupForm() {
        form
        +++ Section("ユーザー情報")
        <<< LabelRow() {
            $0.title = "ユーザーネーム"
            $0.value = karupasu.userModel.name.value.isEmpty ? "Unknown" : karupasu.userModel.name.value
        }
        <<< LabelRow() {
            $0.title = "メールアドレス"
            $0.value = karupasu.userModel.email.value.isEmpty ? "Unknown" : karupasu.userModel.email.value
        }
        
        <<< LabelRow() {
            $0.title = "パスワード"
            $0.value = AppData().userPassword
        }
        
        
        +++ Section("デバッグ情報")
        <<< LabelRow() {
            $0.title = "teamId"
            $0.value = String(karupasu.userModel.teamId.value)
        }
        
        <<< LabelRow() {
            $0.title = "uid"
            $0.value = karupasu.userModel.uid.value.isEmpty ? "Unknown" : karupasu.userModel.uid.value
        }
        
        <<< LabelRow() {
            $0.title = "accessToken"
            $0.value = karupasu.userModel.accessToken.value.isEmpty ? "Unknown" : karupasu.userModel.accessToken.value
        }
        
        <<< LabelRow() {
            $0.title = "client"
            $0.value = karupasu.userModel.client.value.isEmpty ? "Unknown" : karupasu.userModel.client.value
        }
        
        +++ Section(footer: "複数端末での同時利用はできません")
        <<< ButtonRow() {
            $0.title = "ログアウト"
            $0.cell.tintColor = .red
            $0.onCellSelection { [weak self] cell, row in
                guard let self = self else { return }
                self.showAlert(title: "ログアウトしますか?", message: nil) { action in
                    self.karupasu.userModel.logoutAccount().subscribe({ event in
                        guard let isSuccess = event.element, isSuccess else { return }
                        self.showAlert(title: "ログアウトしました", message: nil ) { action in
                        }
                    })
                        .disposed(by: self.disposeBag)
                } cancelAction: { action in
                }
            }
        }
        
        // Enables the navigation accessory and stops navigation when a disabled row is encountered
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        // Enables smooth scrolling on navigation to off-screen rows
        animateScroll = true
        // Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
        rowKeyboardSpacing = 20
    }
}
