//
//  SearchViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol SearchViewStreamType: AnyObject {
    var input: InputWrapper<SearchViewStream.Input> { get }
    var output: OutputWrapper<SearchViewStream.Output> { get }
}

final class SearchViewStream: UnioStream<SearchViewStream>, SearchViewStreamType {

    convenience init(karupasu: Karupasu = .shared,
                     eventViewStream: EventCollectionViewStreamType) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu, eventViewStream: eventViewStream))
    }
}

extension SearchViewStream {

    struct Input: InputType {
        let searchKeyword = PublishRelay<String>()
        let tapFilter = PublishRelay<Void>()
        let setFilter = PublishRelay<(GenreModel.Genre?, PlaceModel.Place?)>()
        let reload = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let showFilterViews: Observable<Void>
    }

    struct State: StateType {
        let keyword = BehaviorRelay<String>(value: "")
        let filter = BehaviorRelay<(GenreModel.Genre?, PlaceModel.Place?)>(value: (nil, nil))
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

        let showFilterView = PublishRelay<Void>()

        input.tapFilter
            .subscribe { _ in
                showFilterView.accept(())
            }
            .disposed(by: disposeBag)

        input.setFilter
            .subscribe { data in
                guard let filter = data.element else { return }
                state.filter.accept(filter)
            }
            .disposed(by: disposeBag)

        input.searchKeyword
            .subscribe { data in
                state.keyword.accept(data.element ?? "")
            }
            .disposed(by: disposeBag)


        Observable.combineLatest(state.keyword,
                                 state.filter,
                                 input.reload)
            .subscribe { (event) in
                let keyword = event.element?.0 ?? ""
                let genre = event.element?.1.0?.id
                let place = event.element?.1.1?.id
                extra.karupasu.eventModel.getEvents(word: keyword, genreId: genre, holdingMethod: place)
                    .subscribe {
                        (events) in
                        print(events)
                        eventViewstream.input.setEvents(events)
                }
                onError: { (error) in

                }.disposed(by: disposeBag)
            }.disposed(by: disposeBag)

        return Output(showFilterViews: showFilterView.asObservable())
    }
}
