//
//  EventApplyViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxSwift
import UIKit
import Unio


/// イベント参加モーダル
final class EventApplyViewController: UIViewController {

    let viewStream: EventApplyViewStreamType = EventApplyViewStream()
    private let disposeBag = DisposeBag()
    var optionFlag = true

    private lazy var eventApplyView: EventApplyView = {
        let view = EventApplyView()
        return view
    }()

    private lazy var prefectureSelectViewController: EventOptionSelectViewController = {
        let vc = EventOptionSelectViewController()
        return vc
    }()

    override func loadView() {
        super.loadView()
        self.view = eventApplyView
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        super.viewWillAppear(animated)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        eventApplyView.prefectureBaseView.rx.viewTap
            .subscribe { [weak self] (event) in
                self?.viewStream.input.tapPrefecture(())
            }
            .disposed(by: disposeBag)

        eventApplyView.confirmBtn.rx.tap
            .subscribe { [weak self] _ in
                self?.viewStream.input.tapConfirm(())
            }
            .disposed(by: disposeBag)

        viewStream.output.showOption
            .subscribe { [weak self] (event) in
                guard let me = self, let event = event.element else { return }
                me.prefectureSelectViewController.viewStream.input.setEvent(event)
                me.showOption()
            }
            .disposed(by: disposeBag)

        viewStream.output.success
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)

        let optionViewStream = prefectureSelectViewController.viewStream
        optionViewStream.output.selectOption
            .skip(1)
            .subscribe { [weak self] (event) in
                guard let prefectures = event.element else { return }
                guard let me = self else { return }
                let message = prefectures.count == 0 ?
                "\(AppText.pleaseSelect())": "\(prefectures.map { $0.name }.joined(separator: "・"))"
                me.eventApplyView.prefectureLbl.text = message
                
                if me.optionFlag {
                    me.viewStream.input.oldOption(prefectures)
                    me.optionFlag = false
                }
            }
            .disposed(by: disposeBag)
        
        optionViewStream.output.confirmOption
            .subscribe { [weak self] event in
                guard let prefectures = event.element else { return }
                guard let me = self else { return }
                me.prefectureSelectViewController.dismiss(animated: true, completion: nil)
                me.viewStream.input.setOption(prefectures)
            }
            .disposed(by: disposeBag)
        
        viewStream.output.updateEvent
            .subscribe { (event) in
                guard let event = event.element else { return }
                optionViewStream.input.setEvent(event)
            }
            .disposed(by: disposeBag)
    }

    private func showOption() {
        pushNewNavigationController(rootViewController: prefectureSelectViewController)
    }
}


extension EventApplyViewController: SemiModalPresenterDelegate {
    var semiModalContentHeight: CGFloat {
        return 180 + view.safeAreaInsets.bottom
    }
}
