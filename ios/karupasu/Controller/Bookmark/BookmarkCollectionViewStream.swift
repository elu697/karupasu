//
//  BookmarkCollectionViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import RxCocoa
import RxSwift
import Unio

protocol BookmarkCollectionViewStreamType: AnyObject {
    var input: InputWrapper<BookmarkCollectionViewStream.Input> { get }
    var output: OutputWrapper<BookmarkCollectionViewStream.Output> { get }
}

final class BookmarkCollectionViewStream: UnioStream<BookmarkCollectionViewStream>, BookmarkCollectionViewStreamType {

    convenience init(karupasu: Karupasu = .shared,
                     eventViewStream: EventCollectionViewStreamType) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu, eventViewStream: eventViewStream))
    }
}

extension BookmarkCollectionViewStream {

    struct Input: InputType {
        let reload = PublishRelay<Void>()
    }
    
    struct Output: OutputType {
    }
    
    struct State: StateType {
    }
    
    struct Extra: ExtraType {
        let karupasu: Karupasu
        let eventViewStream: EventCollectionViewStreamType
    }
    
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        
        let input = dependency.inputObservables
        let state = dependency.state
        let extra = dependency.extra
        let eventViewstream = extra.eventViewStream
        input.reload
            .subscribe { (_) in
                extra.karupasu.eventModel.getFavoriteEvents()
                    .subscribe {
                        (events) in
                        print(events)
                        eventViewstream.input.setEvents(events)
                }
                onError: { (error) in

                }.disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)        
        return Output()
    }
}
