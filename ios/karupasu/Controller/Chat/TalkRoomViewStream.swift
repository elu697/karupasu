//
//  TalkRoomViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxCocoa
import RxSwift
import Unio

protocol TalkRoomViewStreamType: AnyObject {
    var input: InputWrapper<TalkRoomViewStream.Input> { get }
    var output: OutputWrapper<TalkRoomViewStream.Output> { get }
}

final class TalkRoomViewStream: UnioStream<TalkRoomViewStream>, TalkRoomViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension TalkRoomViewStream {
    struct Input: InputType {
        let loadData = PublishRelay<Void>()
    }
    
    struct Output: OutputType {
        let reloadDatasource: Observable<[RoomModel.Room]>
    }
    
    struct State: StateType {
        let currentRooms = BehaviorRelay<[RoomModel.Room]>(value: [])
    }
    
    struct Extra: ExtraType {
        let karupasu: Karupasu
    }
    
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu
        let reloadDatasource = BehaviorRelay<[RoomModel.Room]>(value: [])
        
        karupasu.roomModel.rooms
            .bind(to: state.currentRooms)
            .disposed(by: disposeBag)
        
//        state.currentRooms.accept([.init(roomId: 1, title: "富士山行きたい", prefecture: "関東", participantsCount: 2, imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/FujiSunriseKawaguchiko2025WP.jpg/275px-FujiSunriseKawaguchiko2025WP.jpg", users: [])])
        
        state.currentRooms
            .bind(to: reloadDatasource)
            .disposed(by: disposeBag)
        
        return Output(reloadDatasource: reloadDatasource.asObservable())
    }
}
