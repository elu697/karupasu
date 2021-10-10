//
//  EventDetailViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol EventDetailViewStreamType: AnyObject {
    var input: InputWrapper<EventDetailViewStream.Input> { get }
    var output: OutputWrapper<EventDetailViewStream.Output> { get }
}

final class EventDetailViewStream: UnioStream<EventDetailViewStream>, EventDetailViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension EventDetailViewStream {

    struct Input: InputType {
        let setEvent = PublishRelay<EventModel.Event>()
        let tapApplyButton = PublishRelay<Void>()
        let tapCancelButton = PublishRelay<Void>()
        let tapBookmark = PublishRelay<Void>()
        let reloadTable = PublishRelay<Void>()
        let reloadView = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let reloadView: Observable<EventModel.Event>
        let reloadTable: Observable<EventModel.Event>
        let showConfirm: Observable<EventModel.Event>
    }

    struct State: StateType {
        let currentEvent = BehaviorRelay<EventModel.Event?>(value: nil)
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu

    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let eventModel = dependency.extra.karupasu.eventModel
        let karupasu = dependency.extra.karupasu

        let reloadView = PublishRelay<EventModel.Event>()
        let reloadTable = PublishRelay<EventModel.Event>()
        let showConfirm = PublishRelay<EventModel.Event>()

        input.setEvent
            .withLatest(from: karupasu.prefectureModel.prefectures)
            .withLatest(from: karupasu.genreModel.genres)
            .map { $0.0 }
            .subscribe({ (event) in
                guard let event = event.element else { return }
                eventModel.getEventDetails(eventId: event.id)
                    .subscribe { (event) in
                        state.currentEvent.accept(event)
                        reloadView.accept(event)
                        reloadTable.accept(event)
                } onError: { (error) in
                    }.disposed(by: disposeBag)
                state.currentEvent.accept(event)
            })
            .disposed(by: disposeBag)

        input.tapApplyButton
            .subscribe { _ in
                guard let event = state.currentEvent.value else { return }
                showConfirm.accept(event)
            }
            .disposed(by: disposeBag)

        input.tapCancelButton
            .subscribe { _ in
                guard let event = state.currentEvent.value else { return }
                showConfirm.accept(event)
            }
            .disposed(by: disposeBag)

        input.tapBookmark
            .subscribe { _ in
                guard let event = state.currentEvent.value else { return }
                eventModel.favoriteEvent(eventId: event.id)
                    .subscribe { (isSuccess) in
                        if isSuccess {
                            eventModel.getEventDetails(eventId: event.id)
                                .subscribe { (event) in
                                    state.currentEvent.accept(event)
                                }.disposed(by: disposeBag)
                        } else {
                            state.currentEvent.accept(event)
                        }
                } onError: { (error) in
                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        input.reloadTable
            .subscribe { _ in
                guard let model = state.currentEvent.value else { return }
                reloadTable.accept(model)
            }
            .disposed(by: disposeBag)

        input.reloadView
            .subscribe { _ in
                guard let model = state.currentEvent.value else { return }
                reloadView.accept(model)
                reloadTable.accept(model)
            }
            .disposed(by: disposeBag)

        state.currentEvent
            .subscribe { event in
                guard let model = state.currentEvent.value else { return }
                reloadView.accept(model)
                reloadTable.accept(model)
            }
            .disposed(by: disposeBag)

        return Output(
            reloadView: reloadView.asObservable(),
            reloadTable: reloadTable.asObservable(),
            showConfirm: showConfirm.asObservable()
        )
    }
}
