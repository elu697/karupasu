//
//  TalkViewController.swift
//  karupasu
//
//  Created by El You on 2021/10/23.
//

import RxSwift
import UIKit
import Unio
import MessageKit
import InputBarAccessoryView


class TalkViewController: MessagesViewController {
    
    var messageList: [MockMessage] = [] {
        didSet {
            // messagesCollectionViewをリロード
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            // モックデータを取得
            self.messageList = MockMessage.getMessages()
        }
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupInput()
        setupButton()
        // 背景の色を指定
        messagesCollectionView.backgroundColor = .darkGray
        
        // メッセージ入力時に一番下までスクロール
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupInput(){
        // プレースホルダーの指定
        messageInputBar.inputTextView.placeholder = "入力"
        // 入力欄のカーソルの色を指定
        messageInputBar.inputTextView.tintColor = .red
        // 入力欄の色を指定
        messageInputBar.inputTextView.backgroundColor = .white
    }
    
    private func setupButton(){
        // ボタンの変更
        messageInputBar.sendButton.title = "送信"
        // 送信ボタンの色を指定
        messageInputBar.sendButton.tintColor = .lightGray
    }
}

// MARK: - MessagesDataSource
extension TalkViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return userType.me.data
    }
    
    func otherSender() -> SenderType {
        return userType.you.data
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        return nil
    }
    
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MARK: - MessagesDisplayDelegate
extension TalkViewController: MessagesDisplayDelegate {
    
    // メッセージの色を変更
    func textColor(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // メッセージの背景色を変更している
    func backgroundColor(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        isFromCurrentSender(message: message) ? .darkGray : .cyan
    }
    
    // メッセージの枠にしっぽを付ける
    func messageStyle(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(
        _ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) {
        avatarView.set( avatar: Avatar(initials: message.sender.senderId == "001" ? "😊" : "🥳") )
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
// MARK: - MessagesLayoutDelegate
extension TalkViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        indexPath.section % 3 == 0 ? 10 : 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }
}

// MARK: - MessageCellDelegate
extension TalkViewController: MessageCellDelegate {
    
    //MARK: - Cellのバックグラウンドをタップした時の処理
    func didTapBackground(in cell: MessageCollectionViewCell) {
        print("バックグラウンドタップ")
        closeKeyboard()
    }
    
    //MARK: - メッセージをタップした時の処理
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("メッセージタップ")
        closeKeyboard()
    }
    
    //MARK: - アバターをタップした時の処理
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("アバタータップ")
        closeKeyboard()
    }
    
    //MARK: - メッセージ上部をタップした時の処理
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("メッセージ上部タップ")
        closeKeyboard()
    }
    
    //MARK: - メッセージ下部をタップした時の処理
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("メッセージ下部タップ")
        closeKeyboard()
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension TalkViewController: InputBarAccessoryViewDelegate {
    // 送信ボタンをタップした時の挙動
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let attributedText = NSAttributedString(
            string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        self.messageList.append(message)
        
        self.messageInputBar.inputTextView.text = String()
        self.messageInputBar.invalidatePlugins()
        self.messagesCollectionView.scrollToLastItem()
    }
    
}

extension TalkViewController {
    func closeKeyboard(){
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.messagesCollectionView.scrollToLastItem()
    }
}

struct User: SenderType {
    var senderId: String
    let displayName: String
}

enum userType {
    case me
    case you
    
    var data: SenderType {
        switch self {
            case .me:
                return User(senderId: "001", displayName: "Me")
            case .you:
                return User(senderId: "002", displayName: "You")
        }
    }
}

struct MockMessage: MessageType {
    
    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    
    private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    
    // サンプル用に適当なメッセージ
    static func getMessages() -> [MockMessage] {
        return [
            createMessage(text: "おはよう", user: .me),
            createMessage(text: "wwwwww", user: .me),
            createMessage(text: "おはようございます", user: .you),
            createMessage(text: "wwww", user: .me),
            createMessage(text: "草", user: .you),
        ]
    }
    
    static func createMessage(text: String, user: userType) -> MockMessage {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
        )
        return MockMessage(attributedText: attributedText, sender: user.data, messageId: UUID().uuidString, date: Date())
    }
}
