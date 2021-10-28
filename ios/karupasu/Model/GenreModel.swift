//
//  GenreModel.swift
//  karupasu
//
//  Created by El You on 2021/08/24.
//

import Foundation
import RxSwift
import RxRelay


class GenreModel {
    struct Genre: Hashable, Codable {
        let id: Int
        let name: String

        private enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }

    static let shared: GenreModel = .init()
    private let disposeBag = DisposeBag()
    // Action
    func getGenres() -> Single<[Genre]> {
        return Single<[Genre]>.create { (observer) -> Disposable in
            GenreProvider.shared.rx.request(.getGenres)
                .subscribe { (response) in
                    if let items = try? JSONDecoder().decode([Genre].self, from: response.data), !items.isEmpty {
                        observer(.success(items))
                    } else {
                    }
            } onError: { (error) in
                observer(.error(error))
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func getSafeGenreTitle(id: Int) -> String {
        return genres.value.filter { genre in
            genre.id == id
        }.first?.name ?? ""
    }
    
    func getModel(id: Int) -> GenreModel.Genre? {
        return genres.value.filter { genre in
            genre.id == id
        }.first
    }
    
    func fetchGenre() {
        getGenres()
            .subscribe { [weak self] (gen) in
                guard let self = self else { return }
                self.genres.accept(gen)
            } onError: { (error) in
            }.disposed(by: disposeBag)
    }
    
    // Dispatcher
    // Store
    private(set) var genres = BehaviorRelay<[Genre]>(value: [])

    private init() {
        fetchGenre()
    }
}
