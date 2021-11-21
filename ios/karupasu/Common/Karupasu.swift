//
//  Karupasu.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import Foundation
import UIKit
import Firebase

final public class Karupasu {
    static let shared: Karupasu = .init()

//    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)

    private(set) lazy var userModel: UserModel = .shared
    private(set) lazy var eventModel: EventModel = .shared
    private(set) lazy var prefectureModel: PrefectureModel = .shared
    private(set) lazy var genreModel: GenreModel = .shared
    private(set) lazy var placeModel: PlaceModel = .shared
    private(set) lazy var roomModel: RoomModel = .shared
    private(set) lazy var firestore = Firestore.firestore()
    private(set) lazy var screen: CGRect = UIScreen.main.bounds
    private(set) lazy var statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    private init() {
    }
    
    func setup() {
        _ = userModel
        _ = eventModel
        _ = prefectureModel
        _ = genreModel
        _ = placeModel
        _ = roomModel
    }
}

