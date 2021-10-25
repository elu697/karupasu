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

class ChatModel {
    struct User: Codable {
        let id: Int
        let name: String
        let iconUrl: String
        
        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case iconUrl = "image"
        }
    }
    
    struct Room: Codable {
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
    
    struct Talk: Codable, Equatable {
        let id: Int
        let userId: Int
        let type: Int
        let date: Date
        let read: Bool
    }
    
    private(set) var rooms = BehaviorRelay<[Room]>(value: [])
    
    static let shared: ChatModel = .init()
    private let disposeBag = DisposeBag()
    
    private init() {
    }
}
