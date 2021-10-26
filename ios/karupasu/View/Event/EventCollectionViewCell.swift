//
//  EventCollectionViewCell.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import UIKit
import RxSwift


class EventCollectionViewCell: UICollectionViewCell {
    let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.image = AppImage.mock_thumb()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .appWhiteGray
        return view
    }()

    lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.frame = thumbnailImage.bounds
        view.center = center
        view.alpha = 0.7
        return view
    }()

    let joinedLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.applying()
        lbl.font = .appFontBoldOfSize(11)
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()

    let memberLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.participant()
        lbl.font = .appFontBoldOfSize(9)
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.backgroundColor = .appMain
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        return lbl
    }()

    let placeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.online()
        lbl.font = .appFontOfSize(9)
        lbl.textAlignment = .center
        lbl.textColor = .appMain
        lbl.backgroundColor = .clear
        return lbl
    }()

    let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "title"
        lbl.font = .appFontBoldOfSize(11)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    let bookmarkBtn: UIButtonSwitch = {
        let btn = UIButtonSwitch()
        btn.setSwitchBtn(on: AppImage.button_bookmark_small_yellow(), off: AppImage.button_bookmark_small_white())
        return btn
    }()

    var isJoined: Bool = false {
        willSet {
            self.effectView.isHidden = !newValue
            self.joinedLbl.isHidden = !newValue
        }
    }

    var isBookmarked: Bool = false {
        willSet {
            self.bookmarkBtn.isTapped = newValue
        }
    }

    var cellDisposeBag = DisposeBag()

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                let shrink = CABasicAnimation(keyPath: "transform.scale")
                //アニメーションの間隔
                shrink.duration = 0.1
                //1.0から0.95に小さくする
                shrink.fromValue = 1.0
                shrink.toValue = 0.95
                //自動で元に戻るか
                shrink.autoreverses = false
                //繰り返す回数を1回にする
                shrink.repeatCount = 1
                //アニメーションが終了した状態を維持する
                shrink.isRemovedOnCompletion = false
                shrink.fillMode = CAMediaTimingFillMode.forwards
                //アニメーションの追加
                self.layer.add(shrink, forKey: "shrink")
            } else {
                let shrink = CABasicAnimation(keyPath: "transform.scale")
                //アニメーションの間隔
                shrink.duration = 0.1
                //1.0から0.95に小さくする
                shrink.fromValue = 0.95
                shrink.toValue = 1.0
                //自動で元に戻るか
                shrink.autoreverses = false
                //繰り返す回数を1回にする
                shrink.repeatCount = 1
                //アニメーションが終了した状態を維持する
                shrink.isRemovedOnCompletion = false
                shrink.fillMode = CAMediaTimingFillMode.forwards
                //アニメーションの追加
                self.layer.add(shrink, forKey: "shrink")
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellDisposeBag = .init()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(thumbnailImage)
        addSubview(effectView)
        addSubview(joinedLbl)
        addSubview(memberLbl)
        addSubview(placeLbl)
        addSubview(titleLbl)
        addSubview(bookmarkBtn)

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.appGray.cgColor
        layer.masksToBounds = true
        initLayout()
    }
    
    func initLayout() {
        thumbnailImage.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.55)
            make.centerX.top.equalToSuperview()
        }
        
        effectView.snp.makeConstraints { (make) in
            make.edges.equalTo(thumbnailImage)
        }
        
        joinedLbl.snp.makeConstraints { (make) in
            make.edges.equalTo(thumbnailImage)
        }
        
        memberLbl.snp.makeConstraints { (make) in
            make.width.equalTo(77)
            make.height.equalTo(19)
            make.top.equalTo(thumbnailImage.snp.bottom).offset(12)
            make.left.equalTo(8)
        }
        
        placeLbl.snp.makeConstraints { (make) in
            make.width.equalTo(45)
            make.height.equalTo(15)
            make.centerY.equalTo(memberLbl)
            make.left.equalTo(memberLbl.snp.right).offset(30)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview().inset(12)
            make.top.equalTo(memberLbl.snp.bottom)
        }
        
        bookmarkBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.bottom.right.equalTo(thumbnailImage).inset(5)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    func cellSetup(model: EventModel.Event) {
        self.thumbnailImage.setImageByKingfisher(with: try? model.imageUrl.asURL())
        if let isJoin = model.isJoined {
            self.isJoined = isJoin == 1
        }
        if let isBookmark = model.isBookmark {
            self.isBookmarked = isBookmark == 1
        }
        self.memberLbl.text = "\(AppText.participant()) \(model.participantsCount ?? 0)/\(model.maxParticipantsCount)"
        self.placeLbl.text = Karupasu.shared.placeModel.getModel(id: model.place)?.name ?? ""
        self.titleLbl.text = model.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
