//
//  EventCreateViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol EventCreateViewStreamType: AnyObject {
    var input: InputWrapper<EventCreateViewStream.Input> { get }
    var output: OutputWrapper<EventCreateViewStream.Output> { get }
}

final class EventCreateViewStream: UnioStream<EventCreateViewStream>, EventCreateViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension EventCreateViewStream {

    struct Input: InputType {
        let thumbnailSet = PublishRelay<UIImage>()
        let titleEdit = PublishRelay<String>()
        let memberEdit = PublishRelay<Int>()
        let placeSelect = PublishRelay<PlaceModel.Place>()
        let genreSelect = PublishRelay<GenreModel.Genre>()
        let tapConfirm = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let checkData: Observable<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>
    }

    struct State: StateType {
        let current = BehaviorRelay<(String?, Int?, PlaceModel.Place?, GenreModel.Genre?, UIImage?)>(value: (nil, nil, nil, nil, nil))
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state

        let checkData = PublishRelay<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>()

        Observable.combineLatest(input.titleEdit.asObservable(),
                                 input.memberEdit.asObservable(),
                                 input.placeSelect.asObservable(),
                                 input.genreSelect.asObservable(),
                                 input.thumbnailSet.asObservable())
            .subscribe { (event) in
                guard let title = event.element?.0,
                    let member = event.element?.1,
                    let place = event.element?.2,
                    let genre = event.element?.3,
                    let thumbnail = event.element?.4 else { return }

                state.current.accept((title, member, place, genre, thumbnail))
            }.disposed(by: disposeBag)

        input.tapConfirm
            .map { state.current.value }
            .subscribe { (event) in
                guard let title = event.element?.0,
                    let member = event.element?.1,
                    let place = event.element?.2,
                    let genre = event.element?.3,
                    let thumbnail = event.element?.4 else { return }
                checkData.accept((title, member, place, genre, thumbnail))
            }.disposed(by: disposeBag)
        return Output(
            checkData: checkData.asObservable())
    }
}
