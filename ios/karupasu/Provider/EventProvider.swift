//
//  EventProvider.swift
//  karupasu
//
//  Created by El You on 2021/08/28.
//

import Foundation
import Moya


enum EventProvider {
    case getEvents(word: String, genreId: Int?, holdingMethod: Int?)
    case postEvent(title: String, imageUrl: String, maxMember: Int, place: Int, genreId: Int)
    case getEventDetails(eventId: Int)
    case postApplyEvent(eventId: Int, prefectureId: Int)
    case postCancelEvent(eventId: Int, prefectureId: Int)
    case postFavorite(eventId: Int)
    case getFavoriteEvents
    case getParticipantEvents

    static let shared: MoyaProvider<EventProvider> = {
        let stubClosure = { (target: EventProvider) -> StubBehavior in
            return .never
        }
        let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let plugins = [networkLoggerPlugin]
        return MoyaProvider<EventProvider>(stubClosure: stubClosure, plugins: plugins)
    }()
}

// MARK: - TargetType
extension EventProvider: TargetType {
    var baseURL: URL {
        return URL(string: AppConstants.API.base)!
    }

    var path: String {
        switch self {
        case .getEvents, .postEvent:
            return "/events"
        case .getEventDetails(let eventId):
            return "/events/\(eventId)"
        case .postApplyEvent(let eventId, _):
            return "/events/\(eventId)/apply"
        case .postCancelEvent(let eventId, _):
            return "/events/\(eventId)/cancel"
        case .postFavorite(let eventId):
            return "/events/\(eventId)/favorite"
        case .getFavoriteEvents:
            return "/events/favorites"
        case .getParticipantEvents:
            return "/events/participants"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getEvents, .getEventDetails, .getFavoriteEvents, .getParticipantEvents:
            return .get
        case .postEvent, .postApplyEvent, .postCancelEvent, .postFavorite:
            return .post
        }
    }

    var sampleData: Data {
        switch self {
        case .getEvents:
            let path = Bundle.main.path(forResource: "events", ofType: "json")!
            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        case .postEvent:
            let path = Bundle.main.path(forResource: "event_create", ofType: "json")!
            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        case .getEventDetails:
            let path = Bundle.main.path(forResource: "event_details", ofType: "json")!
            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        case .getFavoriteEvents:
            let path = Bundle.main.path(forResource: "events_favorites", ofType: "json")!
            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        case .getParticipantEvents:
            let path = Bundle.main.path(forResource: "events_participants", ofType: "json")!
            return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
        case .postApplyEvent, .postCancelEvent, .postFavorite:
            return .empty
        }
    }

    var task: Task {
        switch self {
        case .getEvents(let word, let genreId, let holdingMethod):
            var params: [String: Any] = [:]
            if !word.isEmpty { params["word"] = word }
            if let genreId = genreId { params["genre_id"] = genreId }
            if let holdingMethod = holdingMethod { params["holding_method"] = holdingMethod }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .postEvent(let title, let imageUrl, let maxMember, let place, let genreId):
            return .requestParameters(parameters: ["title": title, "image": imageUrl, "maximum_participants_count": maxMember, "holding_method": place, "genre_id": genreId], encoding: URLEncoding.default)
        case .postApplyEvent(_, let prefectureId):
            return .requestParameters(parameters: ["prefecture_id": prefectureId], encoding: URLEncoding.default)
        case .postCancelEvent(_, let prefectureId):
            return .requestParameters(parameters: ["prefecture_id": prefectureId], encoding: URLEncoding.default)
        case .getEventDetails, .getFavoriteEvents, .getParticipantEvents, .postFavorite:
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
