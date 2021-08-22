//
//  RegistrationViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol RegistrationViewStreamType: AnyObject {
    var input: InputWrapper<RegistrationViewStream.Input> { get }
    var output: OutputWrapper<RegistrationViewStream.Output> { get }
}

final class RegistrationViewStream: UnioStream<RegistrationViewStream>, RegistrationViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension RegistrationViewStream {

    struct Input: InputType {
        let editName = PublishRelay<String?>()
        let editMailAddress = PublishRelay<String?>()
        let editPassword = PublishRelay<String?>()
        let tapRegistration = PublishRelay<Void>()
        let tapLogin = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let end: Observable<Void>
        let login: Observable<Void>
        let showError: Observable<String>
    }

    struct State: StateType {
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {

        let input = dependency.inputObservables
        let karupasu = dependency.extra.karupasu

        let end = PublishRelay<Void>()
        let login = PublishRelay<Void>()
        let showError = PublishRelay<String>()

        input.tapLogin
            .subscribe { _ in
                login.accept(())
            }
            .disposed(by: disposeBag)

        input.tapRegistration
            .withLatest(from: input.editName)
            .withLatest(from: input.editMailAddress)
            .withLatest(from: input.editPassword)
            .subscribe { (name, mail, pass) in
                guard let name = name,
                    let mail = mail,
                    let pass = pass,
                      !name.isEmpty, !mail.isEmpty, !pass.isEmpty else {
                        showError.accept("情報を入力してください")
                        return
                }
                karupasu.userModel.registerAccount(name: name, mail: mail, pass: pass).subscribe { (event) in
                    guard let isRegister = event.element else {
                        showError.accept("通信エラー")
                        return }
                    if isRegister {
                        karupasu.userModel.loginAccount(mail: mail, pass: pass).subscribe { (event2) in
                            guard let isLogin = event2.element else {
                                showError.accept("登録に成功しましたが\nログインに失敗しました")
                                return }
                            if isLogin {
                                end.accept(())
                                karupasu.userModel.saveUserData().subscribe().disposed(by: disposeBag)
                            } else {
                                showError.accept("登録に成功しましたが\nログインに失敗しました")
                            }
                        }.disposed(by: disposeBag)
                    } else {
                        showError.accept("登録に失敗しました")
                    }
                }.disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        return Output(end: end.asObservable(),
                      login: login.asObservable(),
                      showError: showError.asObservable()
        )
    }
}
