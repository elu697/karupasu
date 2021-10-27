//
//  ScreenOverViewController.swift
//  karupasu
//
//  Created by El You on 2021/10/26.
//

import RxSwift
import UIKit
import Unio

final class ScreenOverViewController: UIViewController {

    let viewStream: ScreenOverViewStreamType = ScreenOverViewStream()
    private let disposeBag = DisposeBag()
    
    lazy var screenOverView: ScreenOverView = {
        return .init(frame: self.view.frame)
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = screenOverView
        self.view.backgroundColor = .clear
//        self.screenOverView.alpha = 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.rx.viewTap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.dismissView()
            }
            .disposed(by: disposeBag)
    }
}
