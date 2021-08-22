//
//  UserProvider.swift
//  karupasu
//
//  Created by El You on 2021/08/28.
//

import Foundation
import Moya


enum UsereProvider {
    case searchTeam(code: String)
    case signUp(email: String, pass: String, teamId: Int, name: String)
    case signIn(email: String, pass: String)

    static let shared: MoyaProvider<UsereProvider> = {
        let stubClosure = { (target: UsereProvider) -> StubBehavior in
            return .never
        }
        let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let plugins = [networkLoggerPlugin]
        return MoyaProvider<UsereProvider>(stubClosure: stubClosure, plugins: plugins)
    }()
}

// MARK: - TargetType
extension UsereProvider: TargetType {
    var baseURL: URL {
        return URL(string: AppConstants.API.base)!
    }

    var path: String {
        switch self {
        case .searchTeam:
            return "/teams/search"
        case .signUp:
            return "/auth"
        case .signIn:
            return "/auth/sign_in"
        }
    }

    var method: Moya.Method {
        switch self {
        case .searchTeam:
            return .get
        case .signUp, .signIn:
            return .post
        }
    }

    var sampleData: Data {
        switch self {
        case .searchTeam:
            let json = """
                        {
                        "id": 1,
                        "code": "Sansan",
                        "created_at": "2021-08-25T16:06:51.749Z",
                        "updated_at": "2021-08-25T16:06:51.749Z"
                        }
                    """
            return json.data(using: .utf8) ?? .empty
        case .signUp, .signIn:
            return .empty
        }
    }

    var task: Task {
        switch self {
        case .searchTeam(let code):
            return .requestParameters(parameters: ["code": code], encoding: URLEncoding.default)

        case .signUp(let email, let pass, let teamId, let name):
            return .requestParameters(parameters: ["email": email, "password": pass, "team_id": teamId, "name": name], encoding: URLEncoding.default)
        case .signIn(let email, let pass):
            return .requestParameters(parameters: ["email": email, "password": pass], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .searchTeam, .signUp, .signIn:
            return nil
        }
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
