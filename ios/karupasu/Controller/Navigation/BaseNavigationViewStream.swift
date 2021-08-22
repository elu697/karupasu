//
//  BaseNavigationViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxCocoa
import RxSwift
import Unio

protocol BaseNavigationViewStreamType: AnyObject {
    var input: InputWrapper<BaseNavigationViewStream.Input> { get }
    var output: OutputWrapper<BaseNavigationViewStream.Output> { get }
}

final class BaseNavigationViewStream: UnioStream<BaseNavigationViewStream>, BaseNavigationViewStreamType {

    convenience init(extra: Extra = .init()) {
        self.init(input: Input(),
                  state: State(),
                  extra: extra)
    }
}

extension BaseNavigationViewStream {

    struct Input: InputType {

        /*
         *  EXAMPLE:
         *
         *  let buttonTap = PublishRelay<Void>()
         */
    }

    struct Output: OutputType {
        /*
         *  EXAMPLE:
         *
         *  let isEnabled: Observable<Bool>
         */
    }

    struct State: StateType {

        /*
         *  EXAMPLE:
         *
         *  let isEnabled = BehaviorRelay<Bool>(value: true)
         */
    }

    struct Extra: ExtraType {

    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {

        return Output(
        )
    }
}
