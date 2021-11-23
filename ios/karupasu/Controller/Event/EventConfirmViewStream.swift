//
//  EventConfirmViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol EventConfirmViewStreamType: AnyObject {
    var input: InputWrapper<EventConfirmViewStream.Input> { get }
    var output: OutputWrapper<EventConfirmViewStream.Output> { get }
}


final class EventConfirmViewStream: UnioStream<EventConfirmViewStream>, EventConfirmViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension EventConfirmViewStream {

    struct Input: InputType {
        let setData = PublishRelay<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>()
        let loadData = PublishRelay<Void>()
        let postData = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let showData: Observable<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>
        let postResult: Observable<Bool>
    }

    struct State: StateType {
        let current = BehaviorRelay<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)?>(value: nil)
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu
        let showData = PublishRelay<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>()
        let postResult = PublishRelay<Bool>()

        input.setData
            .bind(to: state.current)
            .disposed(by: disposeBag)

        input.loadData
            .map { _ in state.current.value }
            .filterNil()
            .bind(to: showData)
            .disposed(by: disposeBag)

        input.postData
            .subscribe { (_) in
                guard let data = state.current.value,
                    let imageData = data.4.jpegData(compressionQuality: 0.3) else {
                        postResult.accept(false)
                        return
                }

                karupasu.eventModel.uploadThumbnail(imageData: imageData)
                    .subscribe(onSuccess: { (imageUrl) in
                        karupasu.eventModel.postEvent(title: data.0, imageUrl: imageUrl, maxMember: data.1, place: data.2.id, genreId: data.3.id)
                            .subscribe { (event) in
                                let isSuccess = event.title == data.0
                                postResult.accept(isSuccess)
                        } onError: { (error) in
                                postResult.accept(false)
                            }.disposed(by: disposeBag)
                    })
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

//        state.current
//            .filterNil()
//            .bind(to: showData)
//            .disposed(by: disposeBag)


        return Output(
            showData: showData.asObservable(),
            postResult: postResult.asObservable())
    }
}
