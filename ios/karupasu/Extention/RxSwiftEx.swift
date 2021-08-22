//
//  RxSwiftEx.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import Foundation
import RxSwift
import RxCocoa

public protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? { return self }
}

extension Optional where Wrapped == String {
    public var orEmpty: String {
        return self ?? ""
    }
}

extension ObservableType where Element: OptionalType {
    
    public func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { item -> Observable<Element.Wrapped> in
            if let value = item.value {
                return Observable.just(value)
            } else {
                return Observable.empty()
            }
        }
    }
}

extension ObservableType {
    public func filterWithLatestFrom<O: ObservableConvertibleType>(_ observable: O, closure: @escaping (Element, O.Element) -> Bool) -> Observable<Element> {
        return withLatest(from: observable)
            .filter { closure($0, $1) }
            .map { $0.0 }
    }
    
    public func optionalizeError() -> Observable<Element?> {
        return materialize()
            .filter { !$0.isCompleted } // `.next(.completed)` は無視
            .map { $0.element }         // `.next(.next(element))` をflatten、 `.next(.error(someError))` は nil化
    }
    
    public func nonStop() -> Observable<Element> {
        return optionalizeError()
            .filterNil()
            .concat(Observable.never())
    }
    
    public func combinePrevious(_ initial: Element) -> Observable<(Element, Element)> {
        return scan((initial, initial)) { previousValues, newValue in
            return (previousValues.1, newValue)
        }
    }

    public func `repeat`(_ count: Int) -> Observable<Element> {
        if count <= 0 {
            return .empty()
        }
        let me = self.asObservable()
        if count == 1 {
            return me
        }
        
        return Observable.create { observer in
            let serial = SerialDisposable()
            
            func iterate(_ current: Int) {
                serial.disposable = me.subscribe(
                    onNext: observer.onNext,
                    onError: observer.onError,
                    onCompleted: {
                        let remaining = count - 1
                        if remaining > 0 {
                            iterate(remaining)
                        } else {
                            observer.onCompleted()
                        }
                    },
                    onDisposed: nil
                )
            }
            iterate(count)
            
            return serial
        }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType>(from observable: SecondO) -> Observable<(Element, SecondO.Element)> {
        return withLatestFrom(observable) { ($0, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2>(from observable: SecondO) -> Observable<(E1, E2, SecondO.Element)>
    where Element == (E1, E2) {
        return withLatestFrom(observable) { ($0.0, $0.1, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3>(from observable: SecondO) -> Observable<(E1, E2, E3, SecondO.Element)>
    where Element == (E1, E2, E3) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3, E4>(from observable: SecondO) -> Observable<(E1, E2, E3, E4, SecondO.Element)>
    where Element == (E1, E2, E3, E4) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $0.3, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3, E4, E5>(from observable: SecondO) -> Observable<(E1, E2, E3, E4, E5, SecondO.Element)>
    where Element == (E1, E2, E3, E4, E5) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $0.3, $0.4, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3, E4, E5, E6>(from observable: SecondO) -> Observable<(E1, E2, E3, E4, E5, E6, SecondO.Element)>
    where Element == (E1, E2, E3, E4, E5, E6) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3, E4, E5, E6, E7>(from observable: SecondO) -> Observable<(E1, E2, E3, E4, E5, E6, E7, SecondO.Element)>
    where Element == (E1, E2, E3, E4, E5, E6, E7) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3, E4, E5, E6, E7, E8>(from observable: SecondO) -> Observable<(E1, E2, E3, E4, E5, E6, E7, E8, SecondO.Element)>
    where Element == (E1, E2, E3, E4, E5, E6, E7, E8) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $1) }
    }
    
    public func withLatest<SecondO: ObservableConvertibleType, E1, E2, E3, E4, E5, E6, E7, E8, E9>(from observable: SecondO) -> Observable<(E1, E2, E3, E4, E5, E6, E7, E8, E9, SecondO.Element)>
    where Element == (E1, E2, E3, E4, E5, E6, E7, E8, E9) {
        return withLatestFrom(observable) { ($0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7, $0.8, $1) }
    }
    
    /// - Note: `resultSelector`なし `withLatestFrom()` と同じ。
    public func withLatest<SecondO: ObservableConvertibleType>(from observable: SecondO) -> Observable<SecondO.Element>
    where Element == Void {
        return withLatestFrom(observable)
    }
}

// MARK: - Transduce

extension ObservableType {
    public func transduce<State, Output>(
        into initial: State,
        _ f: @escaping (inout State, Element) -> Output
    ) -> Observable<Output> {
        
        return self
            .scan(into: (initial, Optional<Output>.none), accumulator: { tuple, element in
                let output = f(&tuple.0, element)
                tuple.1 = output
            })
            .flatMap { tuple -> Observable<Output> in
                if let output = tuple.1 {
                    return .just(output)
                } else {
                    return .empty()
                }
            }
    }
}

