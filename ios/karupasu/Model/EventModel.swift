//
//  EventModel.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseStorage


class EventModel {
    struct EventDetail: Codable {
        let prefecture: Int //0 オンライン
        let isJoined: Int
        let participantsCount: Int
        let participantsNames: [String]
        var maxParticipantsCount: Int? // 仕方なくvar
        
        private enum CodingKeys: String, CodingKey {
            case prefecture = "prefecture_id"
            case isJoined = "participation"
            case participantsCount = "participants_count"
            case maxParticipantsCount = "max_participant_count"
            case participantsNames = "participants_names"
        }
    }

    struct Event: Codable {
        let id: Int
        let title: String
        let imageUrl: String
        let genreId: Int
        let place: Int //0 オンライン
        let isJoined: Int?
        let isBookmark: Int?
        let participantsCount: Int?
        let maxParticipantsCount: Int
        let details: [EventDetail]?


        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case title = "title"
            case imageUrl = "image"
            case genreId = "genre_id"
            case place = "holding_method"
            case isJoined = "participation"
            case isBookmark = "favorite"
            case participantsCount = "participants_count"
            case maxParticipantsCount = "maximum_participants_count"
            case details = "details"
        }
    }

    private(set) var event: Event?

    static let shared: EventModel = .init()
    private let disposeBag = DisposeBag()

    // Action
    func getEvents(word: String, genreId: Int?, holdingMethod: Int?) -> Single<[EventModel.Event]> {
        return EventProvider.shared.rx.request(.getEvents(word: word, genreId: genreId, holdingMethod: holdingMethod)).asObservable()
            .map([EventModel.Event].self)
            .asSingle()
    }

    func getFavoriteEvents() -> Single<[EventModel.Event]> {
        return EventProvider.shared.rx.request(.getFavoriteEvents).asObservable()
            .map([EventModel.Event].self)
            .asSingle()
    }

    func getParticipantEvents() -> Single<[EventModel.Event]> {
        return EventProvider.shared.rx.request(.getParticipantEvents).asObservable()
            .map([EventModel.Event].self)
            .asSingle()
    }

    func getEventDetails(eventId: Int) -> Single<EventModel.Event> {
        return EventProvider.shared.rx.request(.getEventDetails(eventId: eventId)).asObservable()
            .map(EventModel.Event.self)
            .asSingle()
    }

    func postEvent(title: String, imageUrl: String, maxMember: Int, place: Int, genreId: Int) -> Single<EventModel.Event> {
        return EventProvider.shared.rx.request(.postEvent(title: title, imageUrl: imageUrl, maxMember: maxMember, place: place, genreId: genreId)).asObservable()
            .map(EventModel.Event.self)
            .asSingle()
    }

    func applyEvent(eventId: Int, prefectureId: Int) -> Single<Bool> {
        return Single<Bool>.create { (observer) -> Disposable in
            EventProvider.shared.rx.request(.postApplyEvent(eventId: eventId, prefectureId: prefectureId)).asObservable()
                .subscribe { (response) in
                    let isSuccess = response.element?.statusCode == 200
                    observer(.success(isSuccess))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    func cancelEvent(eventId: Int, prefectureId: Int) -> Single<Bool> {
        return Single<Bool>.create { (observer) -> Disposable in
            EventProvider.shared.rx.request(.postCancelEvent(eventId: eventId, prefectureId: prefectureId)).asObservable()
                .subscribe { (response) in
                    let isSuccess = response.statusCode == 200
                    observer(.success(isSuccess))
            } onError: { (error) in
                    observer(.success(false))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    func favoriteEvent(eventId: Int) -> Single<Bool> {
        return Single<Bool>.create { (observer) -> Disposable in
            EventProvider.shared.rx.request(.postFavorite(eventId: eventId)).asObservable()
                .subscribe { (response) in
                    let isSuccess = response.statusCode == 200
                    observer(.success(isSuccess))
            } onError: { (error) in
                    observer(.success(false))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    func uploadThumbnail(imageData: Data) -> Single<String> {
        let hashPath = "\(imageData.hashValue.description)\(Date().hashValue.description)".md5()
        let ref = Storage.storage().reference().child("img").child(hashPath)

        return Single.create { observer in
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    observer(.error(error))
                    return
                }
                ref.downloadURL(completion: { (url, error) in
                    if let error = error {
                        observer(.error(error))
                        return
                    }
                    guard let imageUrl = url?.absoluteString else { return }
                    observer(.success((imageUrl)))
                })
            }
            return Disposables.create()
        }
    }

    // Dispatcher
    // Store

    private init() {
    }
}
