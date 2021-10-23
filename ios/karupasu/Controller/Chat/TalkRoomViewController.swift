//
//  TalkRoomViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxSwift
import RxDataSources
import RxCocoa
import UIKit
import Unio


enum RoomSectionModel: IdentifiableType, Equatable {
    case room(data: ChatModel.Room)
    
    var identity: Int {
        switch self {
            case .room(let data):
                return data.roomId
        }
    }
    
    var model: ChatModel.Room {
        switch self {
            case .room(let data):
                return data
        }
    }
    
    static func == (lhs: RoomSectionModel, rhs: RoomSectionModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

/// イベントの絞り込み画面
final class TalkRoomViewController: UITableViewController {
    
    let viewStream: TalkRoomViewStreamType = TalkRoomViewStream()
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, RoomSectionModel>>(configureCell: configureCell)
    
    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, RoomSectionModel>>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TalkRoomTableViewCell else { return .init() }
        cell.selectionStyle = .gray
        cell.separatorInset = .init(top: 0.0, left: 11.0, bottom: 0.0, right: 11.0)
        cell.setModel(model: item.model)
        return cell
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBarTitleString(title: AppText.talkroom())
        tableView.dataSource = nil
        tableView.register(TalkRoomTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let input = viewStream.input
        let output = viewStream.output
        
        tableView.rx.itemSelected
            .subscribe { [weak self] indexPath in
                guard let self = self, let indexPath = indexPath.element else { return }
                let room = self.dataSource.sectionModels[indexPath.section].items[indexPath.item].model
                self.showTalk(room: room)
            }
            .disposed(by: disposeBag)
        
        output.reloadDatasource
            .map { room in
                room.map { RoomSectionModel.room(data: $0) }
            }
            .map { room in
                [AnimatableSectionModel<String, RoomSectionModel>(model: AppText.talkroom(), items: room)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .subscribe { [weak self] (_) in
                guard let self = self else { return }
                
            }
            .disposed(by: disposeBag)
    }
    
    func showTalk(room: ChatModel.Room) {

        // Chatは実装コスト間に合わなそうだからとりあえずOSS使う．
        // データはRxで流してbindする
        let vc = TalkViewController(roomId: String(room.roomId))
        vc.setNavigationBarTitleString(title: room.title)
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
}

extension TalkRoomViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
