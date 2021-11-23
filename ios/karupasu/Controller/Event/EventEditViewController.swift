//
//  EventEditViewController.swift
//  karupasu
//
//  Editd by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import IQKeyboardManagerSwift
import Photos
import SVProgressHUD

/// イベント企画
final class EventEditViewController: UIViewController {

    let viewStream: EventEditViewStreamType = EventEditViewStream()
    private let disposeBag = DisposeBag()
    var event: EventModel.Event?

    lazy var eventEditView: EventCreateView = {
        return .init(frame: self.view.frame)
    }()

    private var eventConfirmViewController: EventUpdateConfirmViewController {
        let vc = EventUpdateConfirmViewController()
        return vc
    }

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
        self.view = eventEditView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        pickerViewController.delegate = self
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        if let event = event {
            eventEditView.thumbnailImage.setImageByKingfisher(with: .init(string: event.imageUrl))
            eventEditView.titleTxf.text = event.title
            eventEditView.memberTxf.text = String(event.maxParticipantsCount)
            eventEditView.placeLbl.text = karupasu.placeModel.getModel(id: event.place)?.name ?? ""
            eventEditView.genreLbl.text = karupasu.genreModel.getSafeGenreTitle(id: event.genreId)
            viewStream.input.setEvent(event)
            
            if let image = eventEditView.thumbnailImage.image,
            let place = karupasu.placeModel.getModel(id: event.place),
            let genre = karupasu.genreModel.getModel(id: event.genreId) {
                self.viewStream.input.thumbnailSet(image)
                viewStream.input.placeSelect(place)
                viewStream.input.genreSelect(genre)
            }
            viewStream.input.titleEdit(event.title)
            viewStream.input.memberEdit(event.maxParticipantsCount)
        }

        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        setRightCloseBarButtonItem(action: #selector(tapDeleteBtn), image: AppImage.button_trash())
        setNavigationBarTitleString(title: AppText.edit())
        eventEditView.gradationView.setGradation()
        setSwipeBack()

        eventEditView.dummyTapView.rx.viewTap
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

        eventEditView.titleTxf.rx.text
            .filterNil()
            .bind(to: viewStream.input.titleEdit)
            .disposed(by: disposeBag)

        eventEditView.memberTxf.rx.text
            .map { Int.init($0 ?? "") }
            .filterNil()
            .bind(to: viewStream.input.memberEdit)
            .disposed(by: disposeBag)

        eventEditView.memberBaseView.rx.viewTap
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                self.eventEditView.memberTxf.becomeFirstResponder()
            }.disposed(by: disposeBag)

        eventEditView.placeBaseView.rx.viewTap
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
                self.eventEditView.placeLbl.text = place.name

            }.disposed(by: disposeBag)

        eventEditView.genreBaseView.rx.viewTap
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
                self.eventEditView.genreLbl.text = genre.name
            }.disposed(by: disposeBag)

        eventEditView.checkBtn.rx.tap
            .bind(to: viewStream.input.tapConfirm)
            .disposed(by: disposeBag)

        viewStream.output.checkData
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                guard let data = event.element else { return }
                let updateEvent = (data.0, data.1, data.2, data.3, data.4, self.event?.id ?? 0)
                let vc = self.eventConfirmViewController
                vc.viewStream.input.setData(updateEvent)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        viewStream.output.showError
            .subscribe { [weak self] (event) in
                guard let errorDis = event.element else { return }
                SVProgressHUD.showError(withStatus: errorDis)
                SVProgressHUD.dismiss(withDelay: 1)
            }
            .disposed(by: disposeBag)
        
        viewStream.output.dissmissEvent
            .subscribe { [weak self] (event) in
                guard let self = self else { return }
                self.dismissView()
            }
            .disposed(by: disposeBag)
    }
    
    @objc
    private func tapDeleteBtn() {
        viewStream.input.tapDelete(())
    }
}

extension EventEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let images = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else { return }
        
        self.eventEditView.thumbnailImage.image = images
        self.eventEditView.tapMessageLbl.isHidden = true
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
