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
        let observe = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let eventCreate: Observable<Void>
        let showLoginProcess: Observable<Void>
        let initializedApp: Observable<RootViewController.initializeStatus>
        let switchView: Observable<RootViewController.presentViewType>
        let showOver: Observable<Void>
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
        let showOver = PublishRelay<Void>()
//        let isFirstisFirstLaunch = BehaviorRelay<Bool>(value: AppData().firstLunch)
//        karupasu.eventModel.deleteEvent(eventId: 13)
        input.launchApp
            .subscribe { _ in
                karupasu.userModel.checkUserData().subscribe({ (event) in
                    guard let isRegistered = event.element else { return }
                    if isRegistered {
                        karupasu.userModel.autoLoginAccount().subscribe { event in
                            let isLogin = event.element ?? false
                            if isLogin {
                                initializedApp.accept(.success)
                            } else {
                                initializedApp.accept(.error(type: .login))
                            }
                        }.disposed(by: disposeBag)
                    } else {
                        initializedApp.accept(.notLogin)
                    }
                }).disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.observe
            .subscribe { _ in
                DispatchQueue.global().async {
                    while true {
                        //脳筋実装 firestoreを使ってやる
                        karupasu.roomModel.fetchRoom()
                        sleep(5)
                    }
                }
                
                karupasu.roomModel.rooms
                    .skip(1)
                    .subscribe { rooms in
                        guard let rooms = rooms.element else { return }
                        var ud = AppData()
                        print("DEBUGGGGG \(rooms.count)\(ud.roomCount)")
                        print(rooms.count, ud.roomCount)
                        if rooms.count > ud.roomCount {
                            showOver.accept(())
                        }
                        ud.roomCount = rooms.count
                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)


        return Output(
            eventCreate: input.eventCreate.asObservable(),
            showLoginProcess: showLoginProcess.asObservable(),
            initializedApp: initializedApp.asObservable(),
            switchView: input.switchView.asObservable(),
            showOver: showOver.asObservable()
        )
    }
}
