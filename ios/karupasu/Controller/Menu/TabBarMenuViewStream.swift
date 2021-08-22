//
//  TabBarMenuViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxCocoa
import RxSwift
import Unio

protocol TabBarMenuViewStreamType: AnyObject {
    var input: InputWrapper<TabBarMenuViewStream.Input> { get }
    var output: OutputWrapper<TabBarMenuViewStream.Output> { get }
}

final class TabBarMenuViewStream: UnioStream<TabBarMenuViewStream>, TabBarMenuViewStreamType {

    convenience init(extra: Extra = .init()) {
        self.init(input: Input(),
                  state: State(),
                  extra: extra)
    }
}

extension TabBarMenuViewStream {

    struct Input: InputType {
        let tapCreateNewEvent = PublishRelay<Void>()
        /*
         *  EXAMPLE:
         *
         *  let buttonTap = PublishRelay<Void>()
         */
    }

    struct Output: OutputType {
        let tapCreateNewEvent: Observable<Void>
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
        let input = dependency.inputObservables
        let state = dependency.state

        /*
         *  EXAMPLE:
         *
         *  dependency.inputObservable(for: \.buttonTap)
         *      .map { _ in false }
         *      .bind(to: state.isEnabled)
         *      .disposed(by: disposeBag)
         */

        return Output(tapCreateNewEvent: input.tapCreateNewEvent.asObservable()
            /*
             * EXAMPLE:
             *
             * isEnabled: state.isEnabled.asObservable()
             */
        )
    }
}
