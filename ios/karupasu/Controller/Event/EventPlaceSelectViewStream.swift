//
//  EventPlaceSelectViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/27.
//

import RxCocoa
import RxSwift
import Unio

protocol EventPlaceSelectViewStreamType: AnyObject {
    var input: InputWrapper<EventPlaceSelectViewStream.Input> { get }
    var output: OutputWrapper<EventPlaceSelectViewStream.Output> { get }
}

final class EventPlaceSelectViewStream: UnioStream<EventPlaceSelectViewStream>, EventPlaceSelectViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: .init(karupasu: karupasu))
    }
}

extension EventPlaceSelectViewStream {

    struct Input: InputType {
        let tapConfirm = PublishRelay<Void>()
        let selectOption = PublishRelay<[PlaceModel.Place]>()
    }

    struct Output: OutputType {
        let reloadDatasource: Observable<([PlaceSectionModel])>
        let selectOption: Observable<([PlaceModel.Place])>
    }

    struct State: StateType {
        let selectedOption = BehaviorRelay<[PlaceModel.Place]>(value: [])
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu

        let reloadDatasource = BehaviorRelay<([PlaceSectionModel])>(value: [])
        let selectOption = BehaviorRelay<([PlaceModel.Place])>(value: [])
        
        karupasu.placeModel.places
            .map({ (genre) in
                genre.map { PlaceSectionModel.place(data: $0) }
            })
            .bind(to: reloadDatasource)
            .disposed(by: disposeBag)
        
        input.tapConfirm
            .subscribe { (_) in
                selectOption.accept(state.selectedOption.value)
            }
            .disposed(by: disposeBag)

        input.selectOption
            .bind(to: state.selectedOption)
            .disposed(by: disposeBag)

        return Output(
            reloadDatasource: reloadDatasource.asObservable(),
            selectOption: selectOption.asObservable())
    }
}
