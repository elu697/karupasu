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
        let reloadDatasource: Observable<[ChatModel.Room]>
    }
    
    struct State: StateType {
        let currentRooms = BehaviorRelay<[ChatModel.Room]>(value: [])
    }
    
    struct Extra: ExtraType {
        let karupasu: Karupasu
    }
    
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu
        let reloadDatasource = BehaviorRelay<[ChatModel.Room]>(value: [])
        
        karupasu.chatModel.rooms
            .bind(to: state.currentRooms)
            .disposed(by: disposeBag)
        
        state.currentRooms.accept([.init(roomId: 1, title: "AA", prefecture: "関東", participantsCount: 1, imageUrl: "", users: [])])
        
        state.currentRooms
            .bind(to: reloadDatasource)
            .disposed(by: disposeBag)
        
        return Output(reloadDatasource: reloadDatasource.asObservable())
    }
}
