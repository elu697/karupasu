//
//  PrefectureProvider.swift
//  karupasu
//
//  Created by El You on 2021/08/28.
//

import Foundation
import Moya


enum PrefectureProvider {
    case getPrefectures
    
    static let shared: MoyaProvider<PrefectureProvider> = {
        let stubClosure = { (target: PrefectureProvider) -> StubBehavior in
            return .never
        }
        let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let plugins = [networkLoggerPlugin]
        return MoyaProvider<PrefectureProvider>(stubClosure: stubClosure)
    }()
}

// MARK: - TargetType
extension PrefectureProvider: TargetType {
    var baseURL: URL {
        return URL(string: AppConstants.API.base)!
    }
    
    var path: String {
        switch self {
            case .getPrefectures:
                return "/prefectures"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getPrefectures:
                return .get
        }
    }
    
    var sampleData: Data {
        switch self {
            case .getPrefectures:
                let path = Bundle.main.path(forResource: "prefectures", ofType: "json")!
                return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        }
    }
    
    var task: Task {
        switch self {
            case .getPrefectures:
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
