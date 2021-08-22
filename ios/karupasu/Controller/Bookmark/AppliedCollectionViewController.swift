//
//  AppliedCollectionViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import RxSwift
import UIKit
import Unio
import XLPagerTabStrip


/// 参加済み企画一覧
final class AppliedCollectionViewController: EventCollectionViewController {

    lazy var appliedViewStream: AppliedCollectionViewStreamType = AppliedCollectionViewStream(eventViewStream: viewStream)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        let input = appliedViewStream.input
        
        rx.viewWillAppear
            .bind(to: input.reload)
            .disposed(by: disposeBag)
    }
}


extension AppliedCollectionViewController: IndicatorInfoProvider {
    //XLPagerTabStrip用
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: self.title)
    }
}
