//
//  EventEditViewStream.swift
//  karupasu
//
//  Editd by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio
import Kingfisher
import SVProgressHUD

protocol EventEditViewStreamType: AnyObject {
    var input: InputWrapper<EventEditViewStream.Input> { get }
    var output: OutputWrapper<EventEditViewStream.Output> { get }
}

final class EventEditViewStream: UnioStream<EventEditViewStream>, EventEditViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension EventEditViewStream {

    struct Input: InputType {
        let setEvent = PublishRelay<EventModel.Event>()
        let thumbnailSet = PublishRelay<UIImage>()
        let titleEdit = PublishRelay<String>()
        let memberEdit = PublishRelay<Int>()
        let placeSelect = PublishRelay<PlaceModel.Place>()
        let genreSelect = PublishRelay<GenreModel.Genre>()
        let tapConfirm = PublishRelay<Void>()
        let tapDelete = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let checkData: Observable<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>
        let showError: Observable<String>
        let dissmissEvent: Observable<Void>
    }

    struct State: StateType {
        let eventId = BehaviorRelay<Int?>(value: nil)
        let current = BehaviorRelay<(String?, Int?, PlaceModel.Place?, GenreModel.Genre?, UIImage?)>(value: (nil, nil, nil, nil, nil))
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let state = dependency.state
        let karupasu = dependency.extra.karupasu
        let checkData = PublishRelay<(String, Int, PlaceModel.Place, GenreModel.Genre, UIImage)>()
        let showError = PublishRelay<String>()
        let dissmissEvent = PublishRelay<Void>()

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
        
        input.setEvent
            .subscribe { (event) in
                guard let title = event.element?.title,
                    let member = event.element?.maxParticipantsCount,
                    let place = event.element?.place,
                    let genre = event.element?.genreId,
                    let thumbnail = event.element?.imageUrl,
                    let placeModel: PlaceModel.Place = karupasu.placeModel.getModel(id: place),
                    let genreModel: GenreModel.Genre = karupasu.genreModel.getModel(id: genre)
                    else { return }
                
                state.current.accept((title, member, placeModel, genreModel, nil))
                state.eventId.accept(event.element?.id)
            }.disposed(by: disposeBag)

        input.tapConfirm
            .map { state.current.value }
            .subscribe { (event) in
                guard let title = event.element?.0,
                    let member = event.element?.1,
                    let place = event.element?.2,
                    let genre = event.element?.3,
                    let thumbnail = event.element?.4 else {
                        showError.accept("全項目を埋めてください")
                        return }
                checkData.accept((title, member, place, genre, thumbnail))
            }.disposed(by: disposeBag)
        
        input.tapDelete
            .map { state.eventId.value }
            .filterNil()
            .subscribe { event in
                guard let id = event.element else { return }
                SVProgressHUD.show()
                karupasu.eventModel.deleteEvent(eventId: id)
                    .subscribe { isSuccess in
                        if isSuccess {
                            SVProgressHUD.dismiss()
                            dissmissEvent.accept(())
                        } else {
                            SVProgressHUD.showError(withStatus: nil)
                        }
                    } onError: { error in
                        
                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)
        
        return Output(
            checkData: checkData.asObservable(),
            showError: showError.asObservable(),
            dissmissEvent: dissmissEvent.asObservable())
    }
}
