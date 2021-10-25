//
//  PrefectureModel.swift
//  karupasu
//
//  Created by El You on 2021/08/24.
//

import Foundation
import RxSwift
import RxRelay


class PrefectureModel {
    struct Prefecture: Codable {
        let id: Int
        let name: String

        private enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }

    static let shared: PrefectureModel = .init()
    private let disposeBag = DisposeBag()
    // Action
    func getPrefectures() -> Single<[Prefecture]> {
        return Single<[Prefecture]>.create { (observer) -> Disposable in
            PrefectureProvider.shared.rx.request(.getPrefectures)
                .subscribe { (response) in
                    if let items = try? JSONDecoder().decode([Prefecture].self, from: response.data), !items.isEmpty {
                        observer(.success(items))
                    }
            } onError: { (error) in
                observer(.error(error))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    func getSafePrefectureTitle(id: Int) -> String {
        return prefectures.value.filter { genre in
            genre.id == id
        }.first?.name ?? ""
    }
    
    func fetchPrefecture() {
        getPrefectures()
            .subscribe { [weak self] (pre) in
                guard let self = self else { return }
                self.prefectures.accept(pre)
            } onError: { (error) in
            }.disposed(by: disposeBag)
    }
    // Dispatcher
    // Store
    private(set) var prefectures = BehaviorRelay<[Prefecture]>(value: [])

    private init() {
        fetchPrefecture()
    }
}
