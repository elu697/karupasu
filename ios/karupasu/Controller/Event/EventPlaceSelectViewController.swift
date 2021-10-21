//
//  EventPlaceSelectViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/27.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit
import Unio


enum PlaceSectionModel: IdentifiableType, Equatable {
    case place(data: PlaceModel.Place)
    
    var identity: String {
        switch self {
            case .place (let data):
                return String(data.id)
        }
    }
    
    var item: PlaceModel.Place {
        switch self {
            case .place(let data):
                return (data)
        }
    }
    
    static func == (lhs: PlaceSectionModel, rhs: PlaceSectionModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

final class EventPlaceSelectViewController: UIViewController {

    let viewStream: EventPlaceSelectViewStreamType = EventPlaceSelectViewStream()
    private let disposeBag = DisposeBag()
    
    private lazy var eventOptionSelectView: EventOptionSelectView = {
        return .init(frame: self.view.frame)
    }()
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, PlaceSectionModel>>(configureCell: configureCell)
    
    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, PlaceSectionModel>>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? OptionTableViewCell else { return .init() }
        cell.selectionStyle = .none
        cell.titleLbl.text = item.item.name
        return cell
    }
    
    override func loadView() {
        super.loadView()
        self.view = eventOptionSelectView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBarTitleString(title: AppText.selectPlace())
        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        eventOptionSelectView.optionTableView.tableFooterView = .init(frame: .zero)
        eventOptionSelectView.optionTableView.allowsMultipleSelection = true
        eventOptionSelectView.optionTableView.register(OptionTableViewCell.self, forCellReuseIdentifier: "Cell")
        eventOptionSelectView.optionTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewStream.output.reloadDatasource
            .map { [AnimatableSectionModel<String, PlaceSectionModel>.init(model: "Genre", items: $0)] }
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
                    me.dataSource.sectionModels[indexPath.section].items[indexPath.row].item
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
                    me.dataSource.sectionModels[indexPath.section].items[indexPath.row].item
                }
                me.viewStream.input.selectOption(items)
            }
            .disposed(by: disposeBag)
        
        // Waring出るけどスルー
        self.rx.viewWillAppear
            .subscribe { [weak self] (_) in
                guard let me = self else { return }
                me.eventOptionSelectView.optionTableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
            }
            .disposed(by: disposeBag)
    }
}

extension EventPlaceSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return indexPath }
        selectedIndexPaths.filter {
            $0.section == indexPath.section
        }.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return indexPath }
        return selectedIndexPaths.filter {
            $0.section == indexPath.section
        }.count == 0 ? indexPath : nil
    }
}
