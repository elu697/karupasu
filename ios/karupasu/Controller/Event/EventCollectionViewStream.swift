//
//  EventCollectionViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import RxCocoa
import RxSwift
import Unio

protocol EventCollectionViewStreamType: AnyObject {
    var input: InputWrapper<EventCollectionViewStream.Input> { get }
    var output: OutputWrapper<EventCollectionViewStream.Output> { get }
}

final class EventCollectionViewStream: UnioStream<EventCollectionViewStream>, EventCollectionViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension EventCollectionViewStream {

    struct Input: InputType {
        let setGenre = PublishRelay<String>()
        let setEvents = PublishRelay<[EventModel.Event]>()
        let tapEvent = PublishRelay<IndexPath>()
        let tapBookmark = PublishRelay<IndexPath>()
    }

    struct Output: OutputType {
        let setGenre: Observable<String>
        let showHeader: Observable<Bool>
        let reloadDatasource: Observable<[EventModel.Event]>
        let showDetail: Observable<EventModel.Event>
        let updateCell: Observable<(EventModel.Event, IndexPath)>
    }

    struct State: StateType {
        let currentEvents = BehaviorRelay<[EventModel.Event]>(value: [])
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {

        let state = dependency.state
        let input = dependency.inputObservables
        let eventModel = dependency.extra.karupasu.eventModel
        let showHeader = BehaviorRelay<Bool>(value: false)
        let reloadDatasource = BehaviorRelay<[EventModel.Event]>(value: [])
        let showDetail = PublishRelay<EventModel.Event>()
        let updateCell = PublishRelay<(EventModel.Event, IndexPath)>()

        input.setGenre
            .map { !$0.isEmpty }
            .bind(to: showHeader)
            .disposed(by: disposeBag)

        input.setEvents
            .subscribe { events in
                guard let events = events.element else { return }
                state.currentEvents.accept(events)
            }
            .disposed(by: disposeBag)

        state.currentEvents
            .bind(to: reloadDatasource)
            .disposed(by: disposeBag)

        input.tapEvent
            .subscribe { event in
                guard let indexPath = event.element else { return }
                let item = state.currentEvents.value[indexPath.item]
                showDetail.accept(item)
            }
            .disposed(by: disposeBag)

        input.tapBookmark
            .subscribe { event in
                guard let indexPath = event.element else { return }
                var items = state.currentEvents.value
                var item = state.currentEvents.value[indexPath.item]

                eventModel.favoriteEvent(eventId: item.id)
                    .subscribe { (isSuccess) in
                        if isSuccess {
                            eventModel.getEventDetails(eventId: item.id)
                                .subscribe { (event) in
                                    items[indexPath.item] = event
                                    updateCell.accept((items[indexPath.item], indexPath))
                                    state.currentEvents.accept(items)
                            } onError: { (error) in

                                }.disposed(by: disposeBag)
                        } else {
                            items[indexPath.item] = item
                            updateCell.accept((items[indexPath.item], indexPath))
                            state.currentEvents.accept(items)
                        }
                } onError: { (error) in

                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        return Output(setGenre: input.setGenre.asObservable(),
                      showHeader: showHeader.asObservable(),
                      reloadDatasource: reloadDatasource.asObservable(),
                      showDetail: showDetail.asObservable(),
                      updateCell: updateCell.asObservable()
        )
    }
}
