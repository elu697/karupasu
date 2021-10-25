//
//  EventOptionSelectViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxCocoa
import RxSwift
import Unio

protocol EventOptionSelectViewStreamType: AnyObject {
    var input: InputWrapper<EventOptionSelectViewStream.Input> { get }
    var output: OutputWrapper<EventOptionSelectViewStream.Output> { get }
}

final class EventOptionSelectViewStream: UnioStream<EventOptionSelectViewStream>, EventOptionSelectViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: .init(karupasu: karupasu))
    }
}

extension EventOptionSelectViewStream {

    struct Input: InputType {
        let reloadView = PublishRelay<Void>()
        let tapConfirm = PublishRelay<Void>()
        let setEvent = PublishRelay<EventModel.Event>()
        let selectOption = PublishRelay<[PrefectureModel.Prefecture]>()
    }

    struct Output: OutputType {
        let reloadDatasource: Observable<([OptionSectionModel])>
        let selectOption: Observable<([PrefectureModel.Prefecture])>
        let confirmOption: Observable<([PrefectureModel.Prefecture])>
    }

    struct State: StateType {
        let currenEvent = BehaviorRelay<EventModel.Event?>(value: nil)
        let selectedOption = BehaviorRelay<[PrefectureModel.Prefecture]>(value: [])
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu

        let reloadDatasource = BehaviorRelay<([OptionSectionModel])>(value: [])
        let selectOption = BehaviorRelay<([PrefectureModel.Prefecture])>(value: [])
        let confirmOption =  BehaviorRelay<([PrefectureModel.Prefecture])>(value: [])

        input.setEvent
            .subscribe({ event in
                state.currenEvent.accept(event.element)
                selectOption.accept(state.selectedOption.value)
            })
            .disposed(by: disposeBag)

        input.tapConfirm
            .subscribe { (_) in
                selectOption.accept(state.selectedOption.value)
                confirmOption.accept(state.selectedOption.value)
            }
            .disposed(by: disposeBag)

        input.selectOption
            .bind(to: state.selectedOption)
            .disposed(by: disposeBag)

        input.reloadView
            .subscribe { (_) in
                guard let current = state.currenEvent.value?.id else { return }
                karupasu.eventModel.getEventDetails(eventId: current)
                    .subscribe { (newEvent) in
                        state.currenEvent.accept(newEvent)
                    }.disposed(by: disposeBag)
            }.disposed(by: disposeBag)
        
//        state.selectedOption
//            .bind(to: selectOption)
//            .disposed(by: disposeBag)

        state.currenEvent
            .subscribe { (event) in
                guard let details = event.element??.details else { return }
                karupasu.prefectureModel.prefectures
                    .subscribe { (prefectures) in
                        guard let prefectures = prefectures.element else { return }
                        let sectionModel = prefectures.map { prefecture -> OptionSectionModel in
                            var detail = details.filter { (detail) -> Bool in
                                detail.prefecture == prefecture.id
                            }.first
                            detail?.maxParticipantsCount = event.element??.maxParticipantsCount ?? nil
                            return OptionSectionModel.prefecture(data: prefecture, subData: detail)
                        }
                        reloadDatasource.accept(sectionModel)
                        
                        let joinPrefecture = sectionModel.filter { model in
                            model.item.1?.isJoined ?? 0 == 1
                        }.map { element in
                            element.item.0
                        }
                        state.selectedOption.accept(joinPrefecture)
                        
                    }.disposed(by: disposeBag)
            }.disposed(by: disposeBag)


        return Output(
            reloadDatasource: reloadDatasource.asObservable(),
            selectOption: selectOption.asObservable(),
            confirmOption: confirmOption.asObservable())
    }
}
