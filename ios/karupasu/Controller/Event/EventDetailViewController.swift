//
//  EventDetailViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit
import Unio


/// イベント詳細面
enum MemberSectionModel: IdentifiableType, Equatable {
    static func == (lhs: MemberSectionModel, rhs: MemberSectionModel) -> Bool {
        lhs.identity == rhs.identity
    }

    case detail(data: EventModel.EventDetail, maxMember: Int)

    var item: (EventModel.EventDetail, Int) {
        switch self {
        case .detail(let data, let maxMember):
            return (data, maxMember)
        }
    }

    var identity: String {
        switch self {
        case .detail(let data, _):
                return String(data.hashValue)
        }
    }
}

final class EventDetailViewController: UIViewController {

    let viewStream: EventDetailViewStreamType = EventDetailViewStream()
    private let disposeBag = DisposeBag()

    private lazy var eventDetailView: EventDetailView = {
        return .init(frame: self.view.frame)
    }()

    private lazy var semiModalPresenter: SemiModalPresenter = {
        let presenter = SemiModalPresenter()
        return presenter
    }()


    private lazy var eventApplyViewController: EventApplyViewController = {
        let vc = EventApplyViewController()
        return vc
    }()
    
    private var eventEditViewController: EventEditViewController {
        let vc = EventEditViewController()
        return vc
    }

    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MemberSectionModel>>(configureCell: configureCell)

    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MemberSectionModel>>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MemberTableViewCell else { return .init() }
        cell.selectionStyle = .none
        cell.titleView.prefectureLbl.text = Karupasu.shared.prefectureModel.getSafePrefectureTitle(id: item.item.0.prefecture)
        cell.titleView.memberLbl.text = "\(item.item.0.participantsCount)人/\(item.item.1)"
        cell.titleView.messageLbl.text = "あと\(item.item.1 - item.item.0.participantsCount)人で開催が決定します"
        cell.detailView.membersTextView.text = item.item.0.participantsNames.joined(separator: "\n")
        cell.titleView.backgroundColor = item.item.0.isJoined == 1 ? UIColor.appWhiteGray : UIColor.white
        cell.detailView.backgroundColor = item.item.0.isJoined == 1 ? UIColor.appWhiteGray : UIColor.white
        return cell
    }

    override func loadView() {
        super.loadView()
        self.view = eventDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        setNavigationBarTitleString(title: AppText.detail())
        setSwipeBack()
        eventDetailView.memberTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: "Cell")
        let input = viewStream.input
        let output = viewStream.output

        eventDetailView.bookmarkBtn.rx.tap
            .bind(to: input.tapBookmark)
            .disposed(by: disposeBag)

        eventDetailView.applyBtn.rx.tap
            .bind(to: input.tapApplyButton)
            .disposed(by: disposeBag)

        eventDetailView.cancelBtn.rx.tap
            .bind(to: input.tapCancelButton)
            .disposed(by: disposeBag)
        
        eventDetailView.editBtn.rx.tap
            .bind(to: input.tapEditButton)
            .disposed(by: disposeBag)

        eventDetailView.memberTableView.rx.setDelegate(self).disposed(by: disposeBag)

        output.reloadView
            .subscribe { [weak self] (event) in
                guard let event = event.element else { return }
                guard let me = self else { return }
                me.eventDetailView.thumbnailImage.setImageByKingfisher(with: URL(string: event.imageUrl))
                
                if let isJoin = event.isJoined {
                    me.eventDetailView.isJoined = isJoin == 1
                } else {
                    let isJoin = event.details?.contains(where: { $0.isJoined == 1 })
                    me.eventDetailView.isJoined = isJoin ?? false
                }
                if let isBookmark = event.isBookmark {
                    me.eventDetailView.bookmarkBtn.isTapped = isBookmark == 1
                }
                me.eventDetailView.thumbnailImage.setImageByKingfisher(with: try? event.imageUrl.asURL())
                me.eventDetailView.titleLbl.text = event.title
                me.eventDetailView.genreLbl.text = "\(AppText.genre()): \(Karupasu.shared.genreModel.getSafeGenreTitle(id: event.genreId))"
                me.eventDetailView.placeLbl.text = Karupasu.shared.placeModel.places.value[event.place].name
                let isHost = event.isHost ?? 0 == 1
                me.eventDetailView.setEditBtn(isHidden: !isHost)
            }
            .disposed(by: disposeBag)

        output.showApply
            .subscribe { [weak self] (event) in
                guard let me = self else { return }
                guard let event = event.element else { return }
                me.showApply(event: event)
            }
            .disposed(by: disposeBag)

        output.reloadTable
            .map { (event) -> [MemberSectionModel] in
                guard let detail = event.details else { return [] }
                let unique = detail.unique()
                return unique.map { MemberSectionModel.detail(data: $0, maxMember: event.maxParticipantsCount) }
            }
            .map { (event) in
                [AnimatableSectionModel<String, MemberSectionModel>(model: AppText.genre(), items: event)]
            }
            .bind(to: eventDetailView.memberTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.showEditBtn
            .subscribe { [weak self] (event) in
                guard let me = self else { return }
                me.eventDetailView.setEditBtn(isHidden: false)
            }
            .disposed(by: disposeBag)
        
        output.showEdit
            .subscribe { [weak self] (event) in
                guard let me = self else { return }
                guard let event = event.element else { return }
                me.showEdit(event: event)
            }
            .disposed(by: disposeBag)

        eventApplyViewController.viewStream.output.success
            .subscribe { [weak self] (event) in
                guard let me = self, let event = event.element else { return }
                me.viewStream.input.setEvent(event)
//                me.viewStream.input.reloadView(())
            }.disposed(by: disposeBag)

        // 多分RxSwiftのバグ?でLayout warningでるから応急処置
        rx.viewWillAppear
            .subscribe { [weak self] (_) in
                guard let me = self else { return }
                me.viewStream.input.reloadView(())
//                me.viewStream.input.reloadTable(())
            }
            .disposed(by: disposeBag)
        
        eventApplyViewController.rx.viewWillDisappear
            .subscribe { [weak self] _ in
                self?.viewWillAppear(true)
            }
            .disposed(by: disposeBag)
    }

    private func showApply(event: EventModel.Event) {
        semiModalPresenter.viewController = eventApplyViewController
        eventApplyViewController.viewStream.input.setEvent(event)
        eventApplyViewController.optionFlag = true
        present(eventApplyViewController, animated: true, completion: nil)
    }
    
    private func showEdit(event: EventModel.Event) {
        let vc = eventEditViewController
        navigationController?.pushViewController(vc, animated: true)
        vc.event = event
    }
}


extension EventDetailViewController: UITableViewDelegate {
//    private func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MemberTableViewCell else { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.eventDetailView.memberTableView.performBatchUpdates(nil)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MemberTableViewCell else { return }
//        UIView.animate(withDuration: 0.2) { [weak self] in
//            self?.eventDetailView.memberTableView.performBatchUpdates({
//                cell.hideDetailView()
//            }, completion: nil)
//        }
    }
}
