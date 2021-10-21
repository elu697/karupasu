//
//  ChatViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import RxSwift
import UIKit
import Unio

/// トーク画面
final class ChatViewController: UITableViewController {

    let viewStream: ChatViewStreamType = ChatViewStream()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = AppText.talkroom()
        
    }
}
