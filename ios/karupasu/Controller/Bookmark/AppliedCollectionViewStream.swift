//
//  AppliedCollectionViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxCocoa
import RxSwift
import Unio

protocol AppliedCollectionViewStreamType: AnyObject {
    var input: InputWrapper<AppliedCollectionViewStream.Input> { get }
    var output: OutputWrapper<AppliedCollectionViewStream.Output> { get }
}

final class AppliedCollectionViewStream: UnioStream<AppliedCollectionViewStream>, AppliedCollectionViewStreamType {

    convenience init(karupasu: Karupasu = .shared,
                     eventViewStream: EventCollectionViewStreamType) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu, eventViewStream: eventViewStream))
    }
}

extension AppliedCollectionViewStream {

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
                extra.karupasu.eventModel.getParticipantEvents()
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
