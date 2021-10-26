//
//  RoomProvider.swift
//  karupasu
//
//  Created by El You on 2021/08/28.
//

import Foundation
import Moya


enum RoomProvider {
    case getRoom
    
    static let shared: MoyaProvider<RoomProvider> = {
        let stubClosure = { (target: RoomProvider) -> StubBehavior in
            return .never
        }
        let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let plugins = [networkLoggerPlugin]
        return MoyaProvider<RoomProvider>(stubClosure: stubClosure, plugins: plugins)
    }()
}

// MARK: - TargetType
extension RoomProvider: TargetType {
    var baseURL: URL {
        return URL(string: AppConstants.API.base)!
    }
    
    var path: String {
        switch self {
            case .getRoom:
                return "/talk_rooms"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getRoom:
                return .get
        }
    }
    
    var sampleData: Data {
        switch self {
            case .getRoom:
                return .empty
        }
    }
    
    var task: Task {
        switch self {
            case .getRoom:
                return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        let headers = ["uid": Karupasu.shared.userModel.uid.value, "client": Karupasu.shared.userModel.client.value, "access-token": Karupasu.shared.userModel.accessToken.value]
        return headers
    }
    
    var validationType: ValidationType {
        return .none
    }
}
