//
//  LoginViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol LoginViewStreamType: AnyObject {
    var input: InputWrapper<LoginViewStream.Input> { get }
    var output: OutputWrapper<LoginViewStream.Output> { get }
}

final class LoginViewStream: UnioStream<LoginViewStream>, LoginViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension LoginViewStream {

    struct Input: InputType {
        let tapLogin = PublishRelay<Void>()
        let editMailAddress = PublishRelay<String?>()
        let editPassword = PublishRelay<String?>()
    }

    struct Output: OutputType {
        let end: Observable<Void>
        let showError: Observable<String>
    }

    struct State: StateType {
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {

        let state = dependency.state
        let input = dependency.inputObservables
        let karupasu = dependency.extra.karupasu
        
        let end = PublishRelay<Void>()
        let showError = PublishRelay<String>()

        input.tapLogin
            .withLatest(from: input.editMailAddress)
            .withLatest(from: input.editPassword)
            .subscribe { (mail, pass) in
                guard let mail = mail,
                      let pass = pass,
                      !mail.isEmpty, !pass.isEmpty else {
                        showError.accept("情報を入力してください")
                        return
                }
                karupasu.userModel.loginAccount(mail: mail, pass: pass).subscribe { (event2) in
                    guard let isLogin = event2.element else {
                        showError.accept("通信エラー")
                        return }
                    if isLogin {
                        end.accept(())
                        karupasu.userModel.saveUserData().subscribe().disposed(by: disposeBag)
                    } else {
                        showError.accept("ログインに失敗しました")
                    }
                }.disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        return Output(end: end.asObservable(),
                      showError: showError.asObservable())
    }
}
