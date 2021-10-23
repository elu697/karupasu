//
//  TalkViewController.swift
//  karupasu
//
//  Created by El You on 2021/10/24.
//

import RxSwift
import UIKit
import Unio
import MessageKit
import MessageInputBar
import InputBarAccessoryView
import CoreLocation


private struct LocationMessageItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}

private struct MediaMessageItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

fileprivate struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    // opt
    
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
    
    init(image: UIImage, sender: SenderType, messageId: String, date: Date) {
        let mediaItem = MediaMessageItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(thumbnail: UIImage, sender: SenderType, messageId: String, date: Date) {
        let mediaItem = MediaMessageItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(location: CLLocation, sender: SenderType, messageId: String, date: Date) {
        let locationItem = LocationMessageItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(emoji: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }
}

fileprivate struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
//    var userImagePath: String
}

// 時間無いのでアーキテクチャ無視．
final class TalkViewController: MessagesViewController {
    let viewStream: TalkViewStreamType = TalkViewStream()
    private let disposeBag = DisposeBag()
    private var messages: [Message] = []
    
    init(roomId: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLeftBackBarButtonItem(image: AppImage.navi_back_blue())
        setSwipeBack()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.image = AppImage.button_send()
//        messageInputBar.toolbarPlaceholder = "メッセージを入力"
        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeyboardBeginsEditing = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true // default false
        let msg = NSAttributedString(
            string: "おめでとうございます!\n参加者が集まったため開催が決定しました!",
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor: UIColor.appMain]
        )
        messages.append(.init(attributedText: msg, sender: Sender(senderId: "admin", displayName: "マッチマッチ"), messageId: UUID().uuidString, date: .init()))
        
        messages.append(.init(text: "よろしくお願いします!", sender: Sender(senderId: "coffee", displayName: "珈琲"), messageId: UUID().uuidString, date: .init()))
    }
}

// messagesDataSource
extension TalkViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        let id = karupasu.userModel.uid.value
        let name = karupasu.userModel.name.value
        return Sender(senderId: id, displayName: name)
    }

    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender.senderId == karupasu.userModel.uid.value
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name,
                                  attributes: [NSAttributedString.Key.font: UIFont.appFontBoldOfSize(9)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

//    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
//
//    }

//    func typingIndicator(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
//
//    }

}

// messagesLayoutDelegate
extension TalkViewController: MessagesLayoutDelegate {
//    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//    }

//    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//    }

//    func typingIndicatorViewSize(in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//    }

//    func typingIndicatorViewTopInset(in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }

//    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

//    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
//
//    }

}

extension TalkViewController: MessagesDisplayDelegate {
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .appMain : .appWhiteGray
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }

//    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
//
//    }

//    func messageFooterView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
//
//    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(initials: message.sender.displayName.first?.description ?? "?")
        avatarView.set(avatar: avatar)
    }

//    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//
//    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.date, .address, .phoneNumber, .transitInformation, .url]
    }

//    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
//
//    }

//    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
//
//    }

//    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        
//    }

//    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
//
//    }

//    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//
//    }

//    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//
//    }

//    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//
//    }

//    func audioProgressTextFormat(_ duration: Float, for audioCell: AudioMessageCell, in messageCollectionView: MessagesCollectionView) -> String {
//
//    }

//    func configureLinkPreviewImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//
//    }

}

extension TalkViewController: MessageCellDelegate {
//    func didTapBackground(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapMessage(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapAvatar(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapImage(in cell: MessageCollectionViewCell) {
//
//    }
//
//    func didTapPlayButton(in cell: AudioMessageCell) {
//
//    }
//
//    func didStartAudio(in cell: AudioMessageCell) {
//
//    }
//
//    func didPauseAudio(in cell: AudioMessageCell) {
//
//    }
//
//    func didStopAudio(in cell: AudioMessageCell) {
//
//    }
}

extension TalkViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                
                let imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messages.append(imageMessage)
                messagesCollectionView.insertSections([messages.count - 1])
                
            } else if let text = component as? String {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                                   .foregroundColor: UIColor.white])
                let message = Message(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messages.append(message)
                messagesCollectionView.insertSections([messages.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
//
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
//
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
//
//    }
}
