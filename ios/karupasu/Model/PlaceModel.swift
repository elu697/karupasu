//
//  PlaceModel.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import Foundation
import RxSwift
import RxRelay


class PlaceModel {
    struct Place: Codable {
        let id: Int
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }
    
    static let shared: PlaceModel = .init()
    private let disposeBag = DisposeBag()
    // Action
    // Dispatcher
    // Store
    func getModel(id: Int) -> PlaceModel.Place? {
        return places.value.filter { palce in
            palce.id == id
        }.first
    }
    
    private(set) var places = BehaviorRelay<[Place]>(value: [])
    
    private init() {
        self.places.accept([.init(id: 0, name: AppText.offline()), .init(id: 1, name: AppText.online())])
    }
}
