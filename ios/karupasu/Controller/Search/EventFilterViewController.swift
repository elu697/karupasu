//
//  EventFilterViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/21.
//

import RxSwift
import RxDataSources
import RxCocoa
import UIKit
import Unio



enum FilterSectionModel: IdentifiableType, Equatable {
    case genre(data: GenreModel.Genre)
    case place(data: PlaceModel.Place)

    var identity: String {
        switch self {
        case .genre(let data):
            return "genre" + String(data.id)
        case .place(let data):
            return "place" + String(data.id)
        }
    }

    var title: String {
        switch self {
        case .genre(let data):
            return data.name
        case .place(let data):
            return data.name
        }
    }

    static func == (lhs: FilterSectionModel, rhs: FilterSectionModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

/// イベントの絞り込み画面
final class EventFilterViewController: UITableViewController {

    let viewStream: EventFilterViewStreamType
    private let disposeBag = DisposeBag()

    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FilterSectionModel>>(configureCell: configureCell)

//    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FilterSectionModel>>(configureCell: configureCell, titleForHeaderInSection: titleForHeaderInSection)

    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FilterSectionModel>>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FilterTableViewCell else { return .init() }
        cell.selectionStyle = .none
        cell.isCheck = false
        cell.titleLbl.text = item.title
        return cell
    }

//    private lazy var titleForHeaderInSection: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FilterSectionModel>>.TitleForHeaderInSection = { [weak self] (dataSource, indexPath) in
//        return dataSource.sectionModels[indexPath].model
//    }

    init(searchViewStream: SearchViewStreamType) {
        viewStream = EventFilterViewStream(searchViewStream: searchViewStream)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.allowsMultipleSelection = true
        tableView.dataSource = nil
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(FilterSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "Header")

        let input = viewStream.input
        let output = viewStream.output

        // nilで全検索
        tableView.rx.itemSelected
            .map { [weak self] _ in self?.tableView.indexPathsForSelectedRows ?? [] }
//            .filterNil()
        .bind(to: input.selectFilter)
            .disposed(by: disposeBag)

        tableView.rx.itemDeselected
            .map { [weak self] _ in self?.tableView.indexPathsForSelectedRows ?? [] }
//            .filterNil()
        .bind(to: input.selectFilter)
            .disposed(by: disposeBag)

        output.reloadDatasource
            .map { (genre, place) in
                (genre.map { FilterSectionModel.genre(data: $0) },
                 place.map { FilterSectionModel.place(data: $0) })
            }
            .map { (genre, place) in
                [AnimatableSectionModel<String, FilterSectionModel>(model: AppText.genre(), items: genre),
                    AnimatableSectionModel<String, FilterSectionModel>(model: AppText.place(), items: place)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .subscribe { (_) in
                Karupasu.shared.genreModel.fetchGenre()
            }
            .disposed(by: disposeBag)
    }
}

extension EventFilterViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33 + 13 // Header + margin
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as? FilterSectionHeaderView else { return nil }
        if section == 0 {
            view.titleLbl.text = AppText.genre()
        } else {
            view.titleLbl.text = AppText.place()
        }
        return view
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return indexPath }
        selectedIndexPaths.filter {
            $0.section == indexPath.section
        }.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        return indexPath
    }

//    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
//        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return indexPath }
//        return selectedIndexPaths.filter {
//            $0.section == indexPath.section
//        }.count == 0 ? indexPath : nil
//    }
}
