//
//  RootViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol RootViewStreamType: AnyObject {
    var input: InputWrapper<RootViewStream.Input> { get }
    var output: OutputWrapper<RootViewStream.Output> { get }
}

final class RootViewStream: UnioStream<RootViewStream>, RootViewStreamType {

    convenience init(extra: Extra = .init()) {
        self.init(input: Input(),
                  state: State(),
                  extra: extra)
    }
}

extension RootViewStream {

    struct Input: InputType {
        let launchApp = PublishRelay<Void>()
        let eventCreate = PublishRelay<Void>()
        let switchView = PublishRelay<RootViewController.presentViewType>()
    }

    struct Output: OutputType {
        let eventCreate: Observable<Void>
        let showLoginProcess: Observable<Void>
        let initializedApp: Observable<RootViewController.initializeStatus>
        let switchView: Observable<RootViewController.presentViewType>
//        let isFirstLaunch: Observable<Bool>
    }

    struct State: StateType {
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu

        init(karupasu: Karupasu = .shared) {
            self.karupasu = karupasu
        }
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let extra = dependency.extra
        let karupasu = extra.karupasu
        let showLoginProcess = PublishRelay<Void>()
        let initializedApp = PublishRelay<RootViewController.initializeStatus>()
//        let isFirstisFirstLaunch = BehaviorRelay<Bool>(value: AppData().firstLunch)

        input.launchApp
            .subscribe { _ in
                karupasu.userModel.checkUserData().subscribe({ (event) in
                    guard let isRegistered = event.element else { return }
                    if isRegistered {
                        initializedApp.accept(.success)
                    } else {
                        initializedApp.accept(.notLogin)
                    }
                }).disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)


        return Output(
            eventCreate: input.eventCreate.asObservable(),
            showLoginProcess: showLoginProcess.asObservable(),
            initializedApp: initializedApp.asObservable(),
            switchView: input.switchView.asObservable())
    }
}
