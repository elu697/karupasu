//
//  OnboardingViewStream.swift
//  karupasu
//
//  Created by El You on 2021/10/25.
//

import RxCocoa
import RxSwift
import Unio

protocol OnboardingViewStreamType: AnyObject {
    var input: InputWrapper<OnboardingViewStream.Input> { get }
    var output: OutputWrapper<OnboardingViewStream.Output> { get }
}

final class OnboardingViewStream: UnioStream<OnboardingViewStream>, OnboardingViewStreamType {

    convenience init(extra: Extra = .init()) {
        self.init(input: Input(),
                  state: State(),
                  extra: extra)
    }
}

extension OnboardingViewStream {

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
