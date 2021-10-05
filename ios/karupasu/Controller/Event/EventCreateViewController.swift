//
//  EventCreateViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import IQKeyboardManagerSwift
import Photos

/// イベント企画
final class EventCreateViewController: UIViewController {

    let viewStream: EventCreateViewStreamType = EventCreateViewStream()
    private let disposeBag = DisposeBag()

    private lazy var eventCreateView: EventCreateView = {
        return .init(frame: self.view.frame)
    }()

    private lazy var eventConfirmViewController: EventConfirmViewController = {
        let vc = EventConfirmViewController()
        return vc
    }()

    private lazy var eventGenreSelectViewController: EventGenreSelectViewController = {
        let vc = EventGenreSelectViewController()
        return vc
    }()

    private lazy var eventPlaceSelectViewController: EventPlaceSelectViewController = {
        let vc = EventPlaceSelectViewController()
        return vc
    }()

    private lazy var pickerViewController: UIImagePickerController = {
        let vc = UIImagePickerController()
        return vc
    }()

    override func loadView() {
        super.loadView()
        self.view = eventCreateView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        pickerViewController.delegate = self
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30

        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        setNavigationBarTitleString(title: AppText.newEvent())
        eventCreateView.gradationView.setGradation()

        eventCreateView.dummyTapView.rx.viewTap
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                if PHPhotoLibrary.authorizationStatus() != .authorized {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .authorized {
                            DispatchQueue.main.async {
                                self.present(self.pickerViewController, animated: true, completion: nil)
                            }
                        } else if status == .denied {
                            // フォトライブラリへのアクセスが許可されていないため、アラートを表示する
                            let alert = UIAlertController(title: "タイトル", message: "メッセージ", preferredStyle: .alert)
                            let settingsAction = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
                                guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                                    return
                                }
                                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                            })
                            let closeAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                            alert.addAction(settingsAction)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.present(self.pickerViewController, animated: true, completion: nil)
                    }
                }
            }
            .disposed(by: disposeBag)

        eventCreateView.titleTxf.rx.text
            .filterNil()
            .bind(to: viewStream.input.titleEdit)
            .disposed(by: disposeBag)

        eventCreateView.memberTxf.rx.text
            .map { Int.init($0 ?? "") }
            .filterNil()
            .bind(to: viewStream.input.memberEdit)
            .disposed(by: disposeBag)

        eventCreateView.memberBaseView.rx.viewTap
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                self.eventCreateView.memberTxf.becomeFirstResponder()
            }.disposed(by: disposeBag)

        eventCreateView.placeBaseView.rx.viewTap
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                self.pushNewNavigationController(rootViewController: self.eventPlaceSelectViewController)
            }.disposed(by: disposeBag)

        eventPlaceSelectViewController.viewStream.output.selectOption
            .subscribe { [weak self] event in
                guard let self = self else { return }
                guard let place = event.element?.first else { return }
                self.eventPlaceSelectViewController.dismiss(animated: true, completion: nil)
                self.viewStream.input.placeSelect(place)
                self.eventCreateView.placeLbl.text = place.name

            }.disposed(by: disposeBag)

        eventCreateView.genreBaseView.rx.viewTap
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                self.pushNewNavigationController(rootViewController: self.eventGenreSelectViewController)
            }.disposed(by: disposeBag)

        eventGenreSelectViewController.viewStream.output.selectOption
            .subscribe { [weak self] event in
                guard let self = self else { return }
                guard let genre = event.element?.first else { return }
                self.eventGenreSelectViewController.dismiss(animated: true, completion: nil)
                self.viewStream.input.genreSelect(genre)
                self.eventCreateView.genreLbl.text = genre.name
            }.disposed(by: disposeBag)

        eventCreateView.checkBtn.rx.tap
            .bind(to: viewStream.input.tapConfirm)
            .disposed(by: disposeBag)

        viewStream.output.checkData
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                guard let data = event.element else { return }
                self.eventConfirmViewController.viewStream.input.setData(data)
                self.navigationController?.pushViewController(self.eventConfirmViewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension EventCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let images = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else { return }
        
        self.eventCreateView.thumbnailImage.image = images
        self.eventCreateView.tapMessageLbl.isHidden = true
        self.viewStream.input.thumbnailSet(images)
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
