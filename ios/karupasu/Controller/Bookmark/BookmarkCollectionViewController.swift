//
//  BookmarkCollectionViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import RxSwift
import UIKit
import Unio
import XLPagerTabStrip


/// お気に入り済み企画一覧
final class BookmarkCollectionViewController: EventCollectionViewController {

    lazy var bookmarkViewStream: BookmarkCollectionViewStreamType = BookmarkCollectionViewStream(eventViewStream: viewStream)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        let input = bookmarkViewStream.input
        let output = bookmarkViewStream.output

        viewStream.output.updateCell
            .map { _ in }
            .bind(to: input.reload)
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .bind(to: input.reload)
            .disposed(by: disposeBag)
    }
}

extension BookmarkCollectionViewController: IndicatorInfoProvider {
    //XLPagerTabStrip用
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: self.title)
    }
}
