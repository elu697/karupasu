//
//  EventFilterViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/21.
//

import RxCocoa
import RxSwift
import Unio

protocol EventFilterViewStreamType: AnyObject {
    var input: InputWrapper<EventFilterViewStream.Input> { get }
    var output: OutputWrapper<EventFilterViewStream.Output> { get }
}

final class EventFilterViewStream: UnioStream<EventFilterViewStream>, EventFilterViewStreamType {

    convenience init(karupasu: Karupasu = .shared,
                     searchViewStream: SearchViewStreamType) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu, searchViewStream: searchViewStream))
    }
}

extension EventFilterViewStream {

    struct Input: InputType {
        let loadData = PublishRelay<Void>()
        let selectFilter = PublishRelay<[IndexPath]>()
    }

    struct Output: OutputType {
        let reloadDatasource: Observable<([GenreModel.Genre], [PlaceModel.Place])>
    }

    struct State: StateType {
        let currentGenres = BehaviorRelay<[GenreModel.Genre]>(value: [])
        let currentPlaces = BehaviorRelay<[PlaceModel.Place]>(value: [])
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
        let searchViewStream: SearchViewStreamType
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu
        let searchViewStream = dependency.extra.searchViewStream
        let reloadDatasource = BehaviorRelay<([GenreModel.Genre], [PlaceModel.Place])>(value: ([], []))

        // First
        karupasu.genreModel.genres
            .subscribe { (event) in
                guard let genres = event.element else { return }
                state.currentGenres.accept(genres)
            }.disposed(by: disposeBag)

        karupasu.placeModel.places
            .subscribe { (event) in
                guard let places = event.element else { return }
                state.currentPlaces.accept(places)
            }.disposed(by: disposeBag)

        Observable.combineLatest(state.currentGenres,
                                 state.currentPlaces)
            .bind(to: reloadDatasource)
            .disposed(by: disposeBag)

        input.selectFilter
            .subscribe { (event) in
                guard let paths = event.element else { return }
                var genre: GenreModel.Genre? = nil
                var place: PlaceModel.Place? = nil
                paths.forEach { (indexPath) in
                    if indexPath.section == 0 {
                        genre = state.currentGenres.value[indexPath.row]
                    } else {
                        place = state.currentPlaces.value[indexPath.row]
                    }
                }
                searchViewStream.input.setFilter((genre, place))
            }
            .disposed(by: disposeBag)

        return Output(
            reloadDatasource: reloadDatasource.asObservable())
    }
}
