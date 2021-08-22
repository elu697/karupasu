//
//  GenreProvider.swift
//  karupasu
//
//  Created by El You on 2021/08/28.
//

import Foundation
import Moya


enum GenreProvider {
    case getGenres

    static let shared: MoyaProvider<GenreProvider> = {
        let stubClosure = { (target: GenreProvider) -> StubBehavior in
            return .never
        }
        let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let plugins = [networkLoggerPlugin]
        return MoyaProvider<GenreProvider>(stubClosure: stubClosure)
    }()
}

// MARK: - TargetType
extension GenreProvider: TargetType {
    var baseURL: URL {
        return URL(string: AppConstants.API.base)!
    }

    var path: String {
        switch self {
        case .getGenres:
            return "/genres"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getGenres:
            return .get
        }
    }

    var sampleData: Data {
        switch self {
        case .getGenres:
            let path = Bundle.main.path(forResource: "genres", ofType: "json")!
            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        }
    }

    var task: Task {
        switch self {
        case .getGenres:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        let headers = ["uid": Karupasu.shared.userModel.uid.value, "client": Karupasu.shared.userModel.client.value, "access-token": Karupasu.shared.userModel.accessToken.value]
        return headers
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
