//
//  EventOptionSelectViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxSwift
import UIKit
import Unio
import RxDataSources


enum OptionSectionModel: IdentifiableType, Equatable {
    case prefecture(data: PrefectureModel.Prefecture, subData: EventModel.EventDetail?)

    var identity: String {
        switch self {
        case .prefecture(let data, _):
            return String(data.id)
        }
    }

    var item: (PrefectureModel.Prefecture, EventModel.EventDetail?) {
        switch self {
        case .prefecture(let data, let subData):
            return (data, subData)
        default:
            break
        }
    }

    static func == (lhs: OptionSectionModel, rhs: OptionSectionModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}


/// イベントの参加時のオプション選択
final class EventOptionSelectViewController: UIViewController {

    let viewStream: EventOptionSelectViewStreamType = EventOptionSelectViewStream()
    private let disposeBag = DisposeBag()

    private lazy var eventOptionSelectView: EventOptionSelectView = {
        return .init(frame: self.view.frame)
    }()

    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, OptionSectionModel>>(configureCell: configureCell)

    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, OptionSectionModel>>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? OptionTableViewCell else { return .init() }
        cell.selectionStyle = .none
        cell.titleLbl.text = item.item.0.name
        let current = item.item.1?.participantsCount ?? 0
        let max = item.item.1?.maxParticipantsCount ?? 0
        let isJoin = (item.item.1?.isJoined ?? 0) == 1
        cell.subTitle.text = (max == 0) ? "" : "\(current)人/\(max)"
        if isJoin {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }

    override func loadView() {
        super.loadView()
        self.view = eventOptionSelectView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBarTitleString(title: AppText.selectPrefectures())
        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        eventOptionSelectView.optionTableView.tableFooterView = .init(frame: .zero)
        eventOptionSelectView.optionTableView.allowsMultipleSelection = true
        eventOptionSelectView.optionTableView.register(OptionTableViewCell.self, forCellReuseIdentifier: "Cell")
        eventOptionSelectView.optionTableView.rx.setDelegate(self).disposed(by: disposeBag)

        viewStream.output.reloadDatasource
            .map { [AnimatableSectionModel<String, OptionSectionModel>.init(model: "Prefecrure", items: $0)] }
            .bind(to: eventOptionSelectView.optionTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        eventOptionSelectView.confirmBtn.rx.tap
            .bind(to: viewStream.input.tapConfirm)
            .disposed(by: disposeBag)

        eventOptionSelectView.optionTableView.rx.itemSelected
            .map { [weak self] _ in self?.eventOptionSelectView.optionTableView.indexPathsForSelectedRows ?? [] }
            .subscribe { [weak self](event) in
                guard let indexPaths = event.element else { return }
                guard let me = self else { return }
                let items = indexPaths.map { indexPath in
                    me.dataSource.sectionModels[indexPath.section].items[indexPath.row].item.0
                }
                me.viewStream.input.selectOption(items)
            }
            .disposed(by: disposeBag)

        eventOptionSelectView.optionTableView.rx.itemDeselected
            .map { [weak self] _ in self?.eventOptionSelectView.optionTableView.indexPathsForSelectedRows ?? [] }
            .subscribe { [weak self](event) in
                guard let indexPaths = event.element else { return }
                guard let me = self else { return }
                let items = indexPaths.map { indexPath in
                    me.dataSource.sectionModels[indexPath.section].items[indexPath.row].item.0
                }
                me.viewStream.input.selectOption(items)
            }
            .disposed(by: disposeBag)
        
        // Waring出るけどスルー
        self.rx.viewWillAppear
            .subscribe { [weak self] (_) in
                guard let me = self else { return }
                me.viewStream.input.reloadView(())
            }
            .disposed(by: disposeBag)
    }
}

extension EventOptionSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return indexPath }
//        selectedIndexPaths.filter {
//            $0.section == indexPath.section
//        }.forEach {
//            tableView.deselectRow(at: $0, animated: true)
//        }
//        return indexPath
//    }
}
