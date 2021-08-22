//
//  FirstTeamViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import SVProgressHUD

/// チームIDの入力画面
final class FirstTeamViewController: UIViewController {

    let viewStream: FirstTeamViewStreamType = FirstTeamViewStream()
    private let rootViewStream: RootViewStreamType
    private let disposeBag = DisposeBag()
    private lazy var firstTeamView: FirstTeamView = {
        return .init(frame: self.view.frame)
    }()

    private lazy var nextViewController: RegistrationViewController = {
        let vc = RegistrationViewController(viewStream: rootViewStream)
        return vc
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
        view = firstTeamView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .appMain
        firstTeamView.teamCodeTxf.keyboardType = .alphabet
        firstTeamView.teamCodeTxf.returnKeyType = .go

        let input = viewStream.input
        let output = viewStream.output
        firstTeamView.teamCodeTxf.rx
            .controlEvent(.editingDidEndOnExit)
            .do { _ in SVProgressHUD.show() }
            .map { [weak self] _ in
                self?.firstTeamView.teamCodeTxf.text ?? "" }
            .bind(to: input.tapEnter)
            .disposed(by: disposeBag)

        output.next
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                SVProgressHUD.dismiss()
                me.navigationController?.pushViewController(me.nextViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.invalid
            .subscribe { text in
                SVProgressHUD.showError(withStatus: text.element ?? "")
                SVProgressHUD.dismiss(withDelay: 1)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstTeamView.teamCodeTxf.becomeFirstResponder()
    }
}
