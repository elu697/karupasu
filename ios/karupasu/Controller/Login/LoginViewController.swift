//
//  LoginViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import SVProgressHUD


/// ログイン画面
final class LoginViewController: UIViewController {

    let viewStream: LoginViewStreamType = LoginViewStream()
    private let disposeBag = DisposeBag()
    private let rootViewStream: RootViewStreamType
    private lazy var loginView: LoginView = {
        return .init(frame: self.view.frame)
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
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appMain

        let input = viewStream.input
        let output = viewStream.output

        loginView.backBtn.rx.tap
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                DispatchQueue.main.async {
                    me.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)

        loginView.mailaddressTxf.rx.text
            .bind(to: input.editMailAddress)
            .disposed(by: disposeBag)

        loginView.passwordTxf.rx.text
            .bind(to: input.editPassword)
            .disposed(by: disposeBag)

        loginView.signinBtn.rx.tap
            .do { _ in SVProgressHUD.show() }
            .bind(to: input.tapLogin)
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
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss(withDelay: 1)
                }
                me.rootViewStream.input.switchView(.normal)
            }
            .disposed(by: disposeBag)




        /*
         *  EXAMPLE:
         *
         *  let input = viewStream.input
         *
         *  button.rx.tap
         *      .bind(to: input.accept(for: \.buttonTap))
         *      .disposed(by: disposeBag)
         */

        /*
         *  EXAMPLE:
         *
         *  let output = viewStream.output
         *
         *  output.observable(for: \.isEnabled)
         *      .bind(to: button.rx.isEnabled)
         *      .disposed(by: disposeBag)
         *
         *  print("rawValue of isEnabled = \(output.value(for: \.isEnabled))")
         */
    }
}
