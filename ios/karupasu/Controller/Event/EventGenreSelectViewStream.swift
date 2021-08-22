//
//  EventGenreSelectViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/27.
//

import RxCocoa
import RxSwift
import Unio


protocol EventGenreSelectViewStreamType: AnyObject {
    var input: InputWrapper<EventGenreSelectViewStream.Input> { get }
    var output: OutputWrapper<EventGenreSelectViewStream.Output> { get }
}

final class EventGenreSelectViewStream: UnioStream<EventGenreSelectViewStream>, EventGenreSelectViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: .init(karupasu: karupasu))
    }
}

extension EventGenreSelectViewStream {

    struct Input: InputType {
        let tapConfirm = PublishRelay<Void>()
        let selectOption = PublishRelay<[GenreModel.Genre]>()
    }

    struct Output: OutputType {
        let reloadDatasource: Observable<([GenreSectionModel])>
        let selectOption: Observable<([GenreModel.Genre])>
    }

    struct State: StateType {
        let selectedOption = BehaviorRelay<[GenreModel.Genre]>(value: [])
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu

        let reloadDatasource = BehaviorRelay<([GenreSectionModel])>(value: [])
        let selectOption = BehaviorRelay<([GenreModel.Genre])>(value: [])

        karupasu.genreModel.genres
            .map({ (genre) in
                genre.map { GenreSectionModel.genre(data: $0) }
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
