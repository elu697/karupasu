//
//  FirstTeamViewStream.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxCocoa
import RxSwift
import Unio

protocol FirstTeamViewStreamType: AnyObject {
    var input: InputWrapper<FirstTeamViewStream.Input> { get }
    var output: OutputWrapper<FirstTeamViewStream.Output> { get }
}

final class FirstTeamViewStream: UnioStream<FirstTeamViewStream>, FirstTeamViewStreamType {

    convenience init(karupasu: Karupasu = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(karupasu: karupasu))
    }
}

extension FirstTeamViewStream {

    struct Input: InputType {
        let tapEnter = PublishRelay<String>()
    }

    struct Output: OutputType {
        let next: Observable<Void>
        let invalid: Observable<String>
    }

    struct State: StateType {
    }

    struct Extra: ExtraType {
        let karupasu: Karupasu
    }

    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let input = dependency.inputObservables
        let karupasu = dependency.extra.karupasu

        let next = PublishRelay<Void>()
        let invalid = PublishRelay<String>()

        input.tapEnter
            .subscribe { text in
                guard let text = text.element, !text.isEmpty else {
                    invalid.accept("コードを入力してください")
                    return
                }
                karupasu.userModel.checkTeamId(teamCode: text).subscribe { (event) in
                    guard let isCorrect = event.element else {
                        invalid.accept("通信エラー")
                        return
                    }
                    if isCorrect {
                        next.accept(())
                    } else {
                        invalid.accept("コードが無効です")
                    }
                }.disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        return Output(next: next.asObservable(),
                      invalid: invalid.asObservable())

    }
}
