//
//  UserModel.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseAuth

class UserModel {
    struct User: Hashable, Codable {
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
    
    func clearUserData(){
        AppData.resetALL()
        let ud = AppData()
        teamId.accept(ud.teamId)
        name.accept(ud.userName)
        email.accept(ud.userMailAddress)
        uid.accept(ud.uid)
        client.accept(ud.client)
        accessToken.accept(ud.accessToken)
    }
    
    
    func logoutAccount() -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                UsereProvider.shared.rx.request(.signOut)
                    .subscribe { response in
                        if response.statusCode == 200 {
                            observer.onNext(true)
                            self.clearUserData()
                        } else {
                            observer.onNext(false)
                        }
                    } onError: { error in
                        observer.onError(error)
                    }
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    func checkTeamId(teamCode: String) -> (Observable<Bool>) {
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                UsereProvider.shared.rx.request(.searchTeam(code: teamCode))
                    .subscribe(onSuccess: { (response) in
                        if response.statusCode == 200 {
                            let json = try? response.mapJSON(failsOnEmptyData: true) as? [String: Any]
                            if let teamId: Int = json?["id"] as? Int {
                                var ud = AppData()
                                ud.teamId = teamId
                                self.teamId.accept(teamId)
                                observer.onNext(true)
                            }
                        } else {
                            observer.onNext(false)
                        }
                    }, onError: { (error) in
                        observer.onError(error)
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
                                var ud = AppData()
                                ud.userName = name
                                ud.userMailAddress = mail
                                ud.userPassword = pass
                                self.name.accept(name)
                                self.email.accept(mail)
                                // TODO FB
                                self.registerUser(email: mail, password: pass)
                                observer.onNext(true)
                            } else {
                                observer.onNext(false)
                            }
                        } onError: { (error) in
                            observer.onError(error)
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
                UsereProvider.shared.rx.request(.signIn(email: mail, pass: pass))
                    .subscribe { (response) in
                        if response.statusCode == 200,
                           let dict = try? JSONSerialization.jsonObject(with: response.data, options: .fragmentsAllowed) as? Dictionary<String, Any>,
                           let name = (dict["data"] as? Dictionary<String, Any>)?["name"] as? String,
                           let uid = response.response?.headers.dictionary["uid"],
                           let client = response.response?.headers.dictionary["client"],
                           let accessToken = response.response?.headers.dictionary["access-token"] {
                            var ud = AppData()
                            ud.uid = uid
                            ud.client = client
                            ud.accessToken = accessToken
                            ud.userMailAddress = mail
                            ud.userName = name
                            ud.userPassword = pass
                            self.uid.accept(uid)
                            self.client.accept(client)
                            self.accessToken.accept(accessToken)
                            self.email.accept(mail)
                            self.name.accept(name)
                            // TODO FB
                            self.loginUser(email: mail, password: pass)
                            observer.onNext(true)
                        } else {
                            observer.onNext(false)
                        }
                    } onError: { (error) in
                        observer.onError(error)
                    }.disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    func autoLoginAccount() -> (Observable<Bool>) {
        let ud = AppData()
        let mail = ud.userMailAddress
        let pass = ud.userPassword
        
        return .create { [weak self] (observer) -> Disposable in
            if let self = self {
                UsereProvider.shared.rx.request(.signIn(email: mail, pass: pass))
                    .subscribe { (response) in
                        if response.statusCode == 200,
                           let uid = response.response?.headers.dictionary["uid"],
                           let client = response.response?.headers.dictionary["client"],
                           let accessToken = response.response?.headers.dictionary["access-token"] {
                            var ud = AppData()
                            ud.uid = uid
                            ud.client = client
                            ud.accessToken = accessToken
                            self.uid.accept(uid)
                            self.client.accept(client)
                            self.accessToken.accept(accessToken)
                            // TODO FB
                            self.loginUser(email: mail, password: pass)
                            observer.onNext(true)
                        } else if response.statusCode == 400 || response.statusCode == 401 {
                            self.clearUserData()
                            observer.onNext(false)
                        } else {
                            observer.onNext(false)
                        }
                    } onError: { (error) in
                        observer.onError(error)
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
    private(set) var FBUser = BehaviorRelay<FirebaseAuth.User?>(value: nil)
    
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
        
        self.autoLogin()
    }
    
    private var authListener: AuthStateDidChangeListenerHandle?
}

extension UserModel {
    private func autoLogin() {
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            let ud = AppData()
            
            if user != nil && ud.uid.isEmpty {
                self.FBUser.accept(user)
            } else {
                let ud = AppData()
                let mail = ud.userMailAddress
                let pass = ud.userPassword
                if !mail.isEmpty && !pass.isEmpty {
                    self.loginUser(email: mail, password: pass)
                }
            }
        })
    }
    
    private func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
        
        }
    }
    
    private func registerUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
        }
    }
    
    private func resetPassword(email: String) {
    }
    
    private func resendVerificationEmail(email: String) {
    }
}

