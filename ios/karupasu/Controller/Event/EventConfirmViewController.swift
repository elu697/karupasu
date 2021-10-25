//
//  EventConfirmViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import SVProgressHUD


/// イベント企画確認
final class EventConfirmViewController: UIViewController {

    let viewStream: EventConfirmViewStreamType = EventConfirmViewStream()
    private let disposeBag = DisposeBag()

    private lazy var eventConfirmView: EventConfirmView = {
        return .init(frame: self.view.frame)
    }()

    override func loadView() {
        super.loadView()
        self.view = eventConfirmView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        setNavigationBarTitleString(title: AppText.check())
        setSwipeBack()

        eventConfirmView.fixBtn.rx.tap
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)

        eventConfirmView.postBtn.rx.tap
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                SVProgressHUD.show()
                self.viewStream.input.postData(())
            }.disposed(by: disposeBag)

        viewStream.output.postResult
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                guard let isSuccess = event.element else { return }
                isSuccess ? SVProgressHUD.showSuccess(withStatus: nil) : SVProgressHUD.showError(withStatus: "")
                SVProgressHUD.dismiss(withDelay: 1)
                if isSuccess { self.dismiss(animated: true, completion: nil) }
            }.disposed(by: disposeBag)

        viewStream.output.showData
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                guard let data = event.element else { return }
                self.eventConfirmView.thumbnailImage.image = data.4
                self.eventConfirmView.titleLbl.text = data.0
                self.eventConfirmView.memberLbl.text = String(data.1)
                self.eventConfirmView.placeLbl.text = data.2.name
                self.eventConfirmView.genreLbl.text = data.3.name
            }.disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewStream.input.loadData(())
    }
}
