//
//  RegistrationViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import SVProgressHUD


/// 新規登録画面
final class RegistrationViewController: UIViewController {

    let viewStream: RegistrationViewStreamType = RegistrationViewStream()
    private let disposeBag = DisposeBag()
    private let rootViewStream: RootViewStreamType
    private lazy var registrationView: RegistrationView = {
        return .init(frame: self.view.frame)
    }()
    private lazy var loginViewController: LoginViewController = {
        return .init(viewStream: rootViewStream)
    }()

    init(viewStream: RootViewStreamType) {
        self.rootViewStream = viewStream
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = registrationView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appMain

        let input = viewStream.input
        let output = viewStream.output

        registrationView.nameTxf.rx.text
            .bind(to: input.editName)
            .disposed(by: disposeBag)

        registrationView.mailaddressTxf.rx.text
            .bind(to: input.editMailAddress)
            .disposed(by: disposeBag)

        registrationView.passwordTxf.rx.text
            .bind(to: input.editPassword)
            .disposed(by: disposeBag)

        registrationView.signupBtn.rx.tap
            .do { _ in SVProgressHUD.show() }
            .bind(to: input.tapRegistration)
            .disposed(by: disposeBag)

        registrationView.signinBtn.rx.tap
            .bind(to: input.tapLogin)
            .disposed(by: disposeBag)

        registrationView.backBtn.rx.tap
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                DispatchQueue.main.async {
                    me.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)

        output.showError
            .subscribe { (event) in
                guard let error = event.element else { return }
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: error)
                    SVProgressHUD.dismiss(withDelay: 1)
                }
            }.disposed(by: disposeBag)

        output.end
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.rootViewStream.input.switchView(.normal)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            .disposed(by: disposeBag)

        output.login
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.navigationController?.pushViewController(me.loginViewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
