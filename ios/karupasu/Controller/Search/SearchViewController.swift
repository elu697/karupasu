//
//  SearchViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio


/// イベント一覧かつ検索と絞り込み
final class SearchViewController: EventCollectionViewController {

    lazy var searchViewStream: SearchViewStreamType = SearchViewStream(eventViewStream: viewStream)
    private let disposeBag = DisposeBag()

    private var searchBar: UISearchBar?

    private lazy var eventFilterViewController: EventFilterViewController = {
        let vc = EventFilterViewController(searchViewStream: searchViewStream)
        return vc
    }()

    private var refreshControll = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard))
        pan.cancelsTouchesInView = false
        view.addGestureRecognizer(pan)

        searchBar = setSearchBar()
        searchBar?.delegate = self
        setRightCloseBarButtonItem(action: #selector(tapGenreButton), image: AppImage.button_filter())
        navigationController?.hidesBarsOnSwipe = false


        let input = searchViewStream.input
        let output = searchViewStream.output

        collectionView.refreshControl = self.refreshControll
        collectionView.refreshControl?.rx.controlEvent(.valueChanged)
            .subscribe({ [weak self] (_) in
                input.reload(())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.refreshControll.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.didScroll
            .subscribe { [weak self] _ in
                self?.searchBar?.resignFirstResponder()
            }
            .disposed(by: disposeBag)

        searchBar?.rx.searchButtonClicked
            .map { [weak self] _ in self?.searchBar?.text }
            .filterNil()
            .bind(to: input.searchKeyword)
            .disposed(by: disposeBag)

        searchBar?.rx.text
            .filterNil()
            .bind(to: input.searchKeyword)
            .disposed(by: disposeBag)

        output.showFilterViews
            .subscribe { [weak self] _ in
                self?.showFilterViewController()
            }
            .disposed(by: disposeBag)

        rx.viewWillAppear
            .bind(to: input.reload)
            .disposed(by: disposeBag)
    }

    private func showFilterViewController() {
        self.searchBar?.resignFirstResponder()
        eventFilterViewController.modalPresentationStyle = .popover
        eventFilterViewController.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height * 0.75)
        //        guard let btn = navigationItem.rightBarButtonItem?.customView else { return }
        //        eventFilterViewController.popoverPresentationController?.sourceView = btn
        //        eventFilterViewController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint.zero,
        //                                                                                     size: .init(width: btn.bounds.width * 1.1, height: btn.bounds.height * 1.1))
        eventFilterViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        eventFilterViewController.popoverPresentationController?.permittedArrowDirections = .up
        eventFilterViewController.popoverPresentationController?.delegate = self
        present(eventFilterViewController, animated: true, completion: nil)
    }

    @objc
    private func tapGenreButton() {
        self.searchViewStream.input.tapFilter(())
    }

    @objc
    private func dissmissKeyboard() {
        searchBar?.resignFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UIPopoverPresentationControllerDelegate {
    // デフォルトの代わりにnoneを返すことで、iPhoneでもpopover表示ができるようになる
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    // Popoverの外をタップしたら閉じるべきかどうかを指定できる（吹き出し内のボタンで閉じたい場合に利用）
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
