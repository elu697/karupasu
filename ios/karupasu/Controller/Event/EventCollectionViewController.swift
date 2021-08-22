//
//  EventCollectionViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit
import Unio



/// イベント一覧表示
struct EventCellModel: IdentifiableType, Equatable {
    static func == (lhs: EventCellModel, rhs: EventCellModel) -> Bool {
        lhs.identity == rhs.identity
    }

    typealias Identity = String
    var identity: String {
        return String(event.id) + "\(event.isBookmark ?? 0)\(event.participantsCount ?? 0)\(event.isJoined ?? 0)"
    }
    let event: EventModel.Event
}

class EventCollectionViewController: UICollectionViewController {

    let viewStream: EventCollectionViewStreamType = EventCollectionViewStream()
    private let disposeBag = DisposeBag()
    private var showGenre = false
    private var genreTitle = ""
    private var dataSource: RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, EventCellModel>>?

    private lazy var eventDetailViewController: EventDetailViewController = {
        let vc = EventDetailViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()

    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        // 168/357, 180/640 168:180 = 200:x x = 200*180/168
        let screen = UIScreen.main.bounds
        let width = screen.width * 0.445
        let height = width * 1.07

        layout.itemSize = .init(width: width, height: height)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return layout
    }()

    override init(collectionViewLayout layout: UICollectionViewLayout = .init()) {
        super.init(collectionViewLayout: flowLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: "MainCell")
        collectionView.register(EventGenreCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")

        let input = viewStream.input
        let output = viewStream.output

        do {
            dataSource = .init(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as? EventCollectionViewCell else {
                    fatalError("NoCell")
                }
                cell.cellSetup(model: item.event)
                cell.bookmarkBtn.rx.tap
                    .subscribe { _ in
                        input.tapBookmark(indexPath)
                    }
                    .disposed(by: cell.cellDisposeBag)
                output.updateCell
                    .filter { $0.1 == indexPath }
                    .map { $0.0 }
                    .subscribe { event in
                        guard let model = event.element else { return }
                        cell.cellSetup(model: model)
                    }
                    .disposed(by: cell.cellDisposeBag)
                return cell

            }, configureSupplementaryView: { [weak self] (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? EventGenreCollectionReusableView else {
                    fatalError("NoHeader")
                }
                header.genreLbl.text = "\(AppText.genre()) : \(self?.genreTitle ?? "")"
                return header
            })
            // RxDatasourceが管理するからnil
            collectionView.dataSource = nil
        }
        
        collectionView.rx.itemSelected
            .bind(to: input.tapEvent)
            .disposed(by: disposeBag)

        output.showHeader
            .subscribe { [weak self] isShow in
                guard let me = self else { return }
                me.showGenre = isShow.element ?? false
                me.collectionView.reloadData()
            }
            .disposed(by: disposeBag)

        output.setGenre
            .subscribe { [weak self] genre in
                guard let me = self, let title = genre.element else { return }
                me.genreTitle = title
                me.collectionView.reloadData()
            }
            .disposed(by: disposeBag)

        output.reloadDatasource
            .map { $0.map { EventCellModel.init(event: $0) } }
            .map { [AnimatableSectionModel<String, EventCellModel>(model: "cell", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)

        output.showDetail
            .subscribe { [weak self] event in
                guard let me = self, let model = event.element else { return }
                me.showDetail(event: model)
            }
            .disposed(by: disposeBag)
        
    }

    private func showDetail(event: EventModel.Event) {
        eventDetailViewController.viewStream.input.setEvent(event)
        pushNewNavigationController(rootViewController: eventDetailViewController) { [weak self] in
            self?.eventDetailViewController.viewStream.input.reloadTable(())
        }
    }
}
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//    }
// RxSwiftがやる
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 20
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath)
//        return cell
//    }

extension EventCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && showGenre {
            return CGSize(width: view.frame.width, height: 50)
        } else {
            return CGSize(width: view.frame.width, height: 0)
        }
    }
}

//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? EventGenreCollectionReusableView else {
//            fatalError("NoHeader")
//        }
//        header.genreLbl.text = "\(AppText.genre()) : \(self.genreTitle)"
//        return header
//    }
