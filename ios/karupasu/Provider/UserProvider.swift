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
    case signOut

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
            case .signOut:
                return "/auth/sign_out"
        }
    }

    var method: Moya.Method {
        switch self {
            case .searchTeam:
                return .get
            case .signUp, .signIn:
                return .post
            case .signOut:
                return .delete
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
            case .signUp, .signIn, .signOut:
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
            case .signOut:
                return .requestPlain
                
        }
    }

    var headers: [String: String]? {
        switch self {
            case .searchTeam, .signUp, .signIn:
                return nil
            case .signOut:
                let headers = ["uid": Karupasu.shared.userModel.uid.value, "client": Karupasu.shared.userModel.client.value, "access-token": Karupasu.shared.userModel.accessToken.value]
                return headers
        }
    }

    var validationType: ValidationType {
        return .none
    }
}
