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

        let state = dependency.state

        /*
         *  EXAMPLE:
         *
         *  dependency.inputObservable(for: \.buttonTap)
         *      .map { _ in false }
         *      .bind(to: state.isEnabled)
         *      .disposed(by: disposeBag)
         */

        return Output(
            /*
             * EXAMPLE:
             *
             * isEnabled: state.isEnabled.asObservable()
             */
        )
    }
}
