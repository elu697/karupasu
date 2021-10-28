//
//  ChatModel.swift
//  karupasu
//
//  Created by El You on 2021/10/21.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseFirestoreSwift
import FirebaseFirestore

class RoomModel {
    struct User: Hashable, Codable {
        let id: Int
        let name: String
        let iconUrl: String
        
        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case iconUrl = "image"
        }
    }
    
    struct Room: Hashable, Codable {
        let roomId: Int
        let title: String
        let prefecture: String
        let participantsCount: Int
        let imageUrl: String
        let users: [User]
        
        private enum CodingKeys: String, CodingKey {
            case roomId = "room_id"
            case title = "title"
            case prefecture = "prefecture"
            case participantsCount = "participants_count"
            case imageUrl = "image"
            case users = "users"
        }
    }
    
    struct Talk: Hashable, Codable, Equatable {
        let id: Int
        let userId: Int
        let type: Int
        let date: Date
        let read: Bool
    }

    static let shared: RoomModel = .init()
    private let disposeBag = DisposeBag()
    
    func getRooms() -> Single<[Room]> {
        return Single<[Room]>.create { (observer) -> Disposable in
            RoomProvider.shared.rx.request(.getRoom)
                .subscribe { (response) in
                    if let items = try? JSONDecoder().decode([Room].self, from: response.data), !items.isEmpty {
                        observer(.success(items))
                    } else {
                    }
                } onError: { (error) in
                    observer(.error(error))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func fetchRoom() {
        getRooms()
            .subscribe { [weak self] (room) in
                guard let self = self else { return }
                self.rooms.accept(room)
            } onError: { (error) in
            }.disposed(by: disposeBag)
    }
    
    private(set) var rooms = BehaviorRelay<[Room]>(value: [])
    
    private init() {
        fetchRoom()
    }
}
