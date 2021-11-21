//
//  EventApplyViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxCocoa
import RxSwift
import Unio

protocol EventApplyViewStreamType: AnyObject {
    var input: InputWrapper<EventApplyViewStream.Input> { get }
    var output: OutputWrapper<EventApplyViewStream.Output> { get }
}

final class EventApplyViewStream: UnioStream<EventApplyViewStream>, EventApplyViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: .init(karupasu: karupasu))
    }
}

extension EventApplyViewStream {

    struct Input: InputType {
        let setEvent = PublishRelay<EventModel.Event>()
        let tapPrefecture = PublishRelay<Void>()
        let setOption = PublishRelay<[PrefectureModel.Prefecture]>()
        let tapConfirm = PublishRelay<Void>()
        let oldOption = PublishRelay<[PrefectureModel.Prefecture]>()
    }

    struct Output: OutputType {
        let showOption: Observable<EventModel.Event>
        let success: Observable<EventModel.Event>
        let updateEvent: Observable<EventModel.Event>
    }

    struct State: StateType {
        let currenEvent = BehaviorRelay<EventModel.Event?>(value: nil)
        let selectedOption = BehaviorRelay<[PrefectureModel.Prefecture]>(value: [])
        let oldOption = BehaviorRelay<[PrefectureModel.Prefecture]>(value: [])
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu

        let showOption = PublishRelay<EventModel.Event>()
        let success = PublishRelay<EventModel.Event>()

        input.setEvent
            .bind(to: state.currenEvent)
            .disposed(by: disposeBag)


        input.setOption
            .bind(to: state.selectedOption)
            .disposed(by: disposeBag)
        
        input.oldOption
            .bind(to: state.oldOption)
            .disposed(by: disposeBag)
        
        state.oldOption
            .skip(1)
            .debug("DEBUGG")
            .subscribe { event in
                
            }
            .disposed(by: disposeBag)
        
        input.tapPrefecture
            .subscribe { (event) in
                guard let event = state.currenEvent.value else { return }
                showOption.accept(event)
            }
            .disposed(by: disposeBag)

        input.tapConfirm
            .subscribe { (_) in
                guard let event = state.currenEvent.value else { return }
                let diff = state.selectedOption.value.map{$0.id}.difference(from: state.oldOption.value.map{$0.id})
                for change in diff {
                    switch change {
                        case let .insert(offset, element, associatedWith):
                            karupasu.eventModel.applyEvent(eventId: event.id, prefectureId: element)
                                .subscribe { (isSuccess) in
                                    success.accept(event)
                                }.disposed(by: disposeBag)
                            break
                        case let .remove(offset, element, associatedWith):
                            karupasu.eventModel.cancelEvent(eventId: event.id, prefectureId: element)
                                .subscribe { (isSuccess) in
                                    success.accept(event)
                                }.disposed(by: disposeBag)
                            break
                    }
                }
            }
            .disposed(by: disposeBag)

        return Output(
            showOption: showOption.asObservable(),
            success: success.asObservable(),
            updateEvent: state.currenEvent.filterNil().asObservable())
    }
}
