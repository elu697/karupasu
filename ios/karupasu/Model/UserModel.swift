//
//  UserModel.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import Foundation
import RxSwift
import RxRelay


class UserModel {
    struct User: Codable {
        let name: String
        let email: String
        let teamId: Int
        let accessToken: String
        let client: String
        let uid: String

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case email = "email"
            case teamId = "team_id"
            case accessToken = "access_token"
            case client = "client"
            case uid = "uid"
        }
    }

    static let shared: UserModel = .init()
    private let disposeBag = DisposeBag()

    // Flux的に実装する
    // Action
    func checkUserData() -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                observer.onNext(self.isRegistered.value)
            }
            return Disposables.create()
        }
    }

    func saveUserData() -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                var ud = AppData()
                ud.teamId = self.teamId.value
                ud.userName = self.name.value
                ud.userMailAddress = self.email.value
                ud.uid = self.uid.value
                ud.client = self.client.value
                ud.accessToken = self.accessToken.value
                observer.onNext(true)
            }
            return Disposables.create()
        }
    }

    func clearUserData() -> (Observable<Bool>) {
        return .create { (observer) -> Disposable in
            AppData.resetALL()
            observer.onNext(true)
            return Disposables.create()
        }
    }

    func checkTeamId(teamCode: String) -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
//                let isValid = !teamCode.isEmpty
//                let isCorrect = teamCode == "sansan" && isValid// チームID検証

                UsereProvider.shared.rx.request(.searchTeam(code: teamCode))
                    .subscribe(onSuccess: { (response) in
                        if response.statusCode == 200 {
                            let json = try? response.mapJSON(failsOnEmptyData: true) as? [String: Any]
                            if let teamId: Int = json?["id"] as? Int {
                                print(teamId)
                                self.teamId.accept(teamId)
                                observer.onNext(true)
                            }
                        } else {
                            observer.onNext(false)
                        }
                    }, onError: { (error) in

                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }

    func registerAccount(name: String, mail: String, pass: String) -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                let isCorrect = !(name.isEmpty || mail.isEmpty || pass.isEmpty)
                if isCorrect, self.teamId.value != 0 {
                    UsereProvider.shared.rx.request(.signUp(email: mail, pass: pass, teamId: self.teamId.value, name: name))
                        .subscribe { (response) in
                            if response.statusCode == 200 {
                                self.name.accept(name)
                                self.email.accept(mail)
                                observer.onNext(true)
                            } else {
                                observer.onNext(false)
                            }
                    } onError: { (error) in
                            observer.onNext(false)
                        }.disposed(by: self.disposeBag)
                } else {
                    observer.onNext(false)
                }
            }
            return Disposables.create()
        }
    }

    func loginAccount(mail: String, pass: String) -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                let isCorrect = !(mail.isEmpty || pass.isEmpty) // ログイン処理
                UsereProvider.shared.rx.request(.signIn(email: mail, pass: pass))
                    .subscribe { (response) in
                        if response.statusCode == 200,
                            let uid = response.response?.headers.dictionary["uid"],
                            let client = response.response?.headers.dictionary["client"],
                            let accessToken = response.response?.headers.dictionary["access-token"] {
                            self.uid.accept(uid)
                            self.client.accept(client)
                            self.accessToken.accept(accessToken)
                            observer.onNext(true)
                        } else {
                            observer.onNext(false)
                        }
                } onError: { (errir) in
                        observer.onNext(false)
                    }.disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }

// Dispatcher
    private(set) var loadUserData = PublishRelay<Bool>()

// Store
    private(set) var teamId = BehaviorRelay<Int>(value: 0)
    private(set) var name = BehaviorRelay<String>(value: "")
    private(set) var email = BehaviorRelay<String>(value: "")
    private(set) var uid = BehaviorRelay<String>(value: "")
    private(set) var client = BehaviorRelay<String>(value: "")
    private(set) var accessToken = BehaviorRelay<String>(value: "")
    private(set) var isRegistered = BehaviorRelay<Bool>(value: false)

    private init() {
        let ud = AppData()
        teamId.accept(ud.teamId)
        name.accept(ud.userName)
        email.accept(ud.userMailAddress)
        uid.accept(ud.uid)
        client.accept(ud.client)
        accessToken.accept(ud.accessToken)

//        print("User: \(ud.teamId), \(ud.userName), \(ud.userMailAddress), \(ud.uid), \(ud.client), \(ud.accessToken)")
        Observable.combineLatest(uid, client, accessToken)
            .subscribe { [weak self] (uid, client, accessToken) in
                guard let self = self else { return }
                let nodata = uid.isEmpty || client.isEmpty || accessToken.isEmpty
                self.isRegistered.accept(!nodata)
            }
            .disposed(by: disposeBag)
    }
}




