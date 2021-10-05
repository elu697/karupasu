//
//  EventCreateView.swift
//  karupasu
//
//  Created by El You on 2021/08/22.
//

import UIKit


// Constraintsで怒られるけれど，原因不明
class EventCreateView: UIView {
    let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .appGray
        return view
    }()

    lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.frame = thumbnailImage.bounds
        view.center = center
        view.alpha = 0
        return view
    }()

    let gradationView: GradationView = {
        let view = GradationView()
        view.alpha = 0.25
        return view
    }()

    let dummyTapView: UIView = {
        let view = UIView()
        return view
    }()

    let tapMessageLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.tapToSelectImage()
        lbl.font = .appFontBoldOfSize(14)
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()

    let titleBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhiteGray
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appGray.cgColor
        return view
    }()

    let titleTxf: UITextField = {
        let txf = UITextField()
        txf.contentVerticalAlignment = .top
        txf.textAlignment = .left
        txf.font = .appFontOfSize(16)
        txf.attributedPlaceholder = NSAttributedString(string: AppText.title(),
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.appGray,
                                                           NSAttributedString.Key.font: UIFont.appFontOfSize(14)])
        return txf
    }()

    let memberBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhiteGray
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appGray.cgColor
        return view
    }()

    let memberTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.numberOfParticipants()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .black
        return lbl
    }()

    let memberTxf: UITextField = {
        let txf = UITextField()
        txf.textAlignment = .right
        txf.keyboardType = .numberPad
        txf.font = .appFontOfSize(16)
        txf.attributedPlaceholder = NSAttributedString(string: AppText.pleaseInput(),
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.appGray,
                                                                    NSAttributedString.Key.font: UIFont.appFontOfSize(14)])
        return txf
    }()

    let placeBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhiteGray
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appGray.cgColor
        return view
    }()

    let placeTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.place()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .black
        return lbl
    }()

    let placeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.pleaseSelect()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .appGray
        return lbl
    }()

    let genreBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhiteGray
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appGray.cgColor
        return view
    }()

    let genreTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.genre()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .black
        return lbl
    }()

    let genreLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.pleaseSelect()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .appGray
        return lbl
    }()
    
    let checkBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appMain
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.doCheck(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        //        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        return btn
    }()

    override public class var layerClass: Swift.AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(thumbnailImage)
        thumbnailImage.addSubview(gradationView)
        thumbnailImage.addSubview(effectView)
        thumbnailImage.addSubview(tapMessageLbl)
        addSubview(dummyTapView)

        titleBaseView.addSubview(titleTxf)
        addSubview(titleBaseView)
        memberBaseView.addSubview(memberTitleLbl)
        memberBaseView.addSubview(memberTxf)
        addSubview(memberBaseView)
        placeBaseView.addSubview(placeTitleLbl)
        placeBaseView.addSubview(placeLbl)
        addSubview(placeBaseView)
        genreBaseView.addSubview(genreTitleLbl)
        genreBaseView.addSubview(genreLbl)
        addSubview(genreBaseView)
        addSubview(checkBtn)
        initLauout()
    }

    func initLauout() {
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(snp.width).multipliedBy(0.64)
        }

        effectView.snp.makeConstraints { (make) in
            make.edges.equalTo(thumbnailImage)
        }

        tapMessageLbl.snp.makeConstraints { (make) in
            make.center.equalTo(effectView)
            make.width.equalTo(182)
            make.height.equalTo(26)
        }

        gradationView.snp.makeConstraints { (make) in
            make.edges.equalTo(thumbnailImage)
        }

        dummyTapView.snp.makeConstraints { (make) in
            make.edges.equalTo(thumbnailImage)
        }

        titleBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(thumbnailImage.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }

        titleTxf.snp.makeConstraints { (make) in
            make.edges.equalTo(titleBaseView).inset(16)
        }

        memberBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(titleBaseView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(titleBaseView)
            make.height.equalTo(48)
        }

        memberTitleLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(memberBaseView).inset(11)
            make.left.equalTo(memberBaseView).inset(16)
        }
        
        memberTxf.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(memberBaseView).inset(11)
            make.right.equalTo(memberBaseView).inset(16)
        }

        placeBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(memberBaseView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(titleBaseView)
            make.height.equalTo(48)
        }

        placeTitleLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(placeBaseView).inset(11)
            make.left.equalTo(placeBaseView).inset(16)
        }
        
        placeLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(placeBaseView).inset(11)
            make.right.equalTo(placeBaseView).inset(16)
        }

        genreBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(placeBaseView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(titleBaseView)
            make.height.equalTo(48)
        }
        
        genreTitleLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(genreBaseView).inset(11)
            make.left.equalTo(genreBaseView).inset(16)
        }
        
        genreLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(genreBaseView).inset(11)
            make.right.equalTo(genreBaseView).inset(16)
        }
        
        checkBtn.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImage.snp.updateConstraints { (make) in
            make.top.equalTo(safeAreaInsets.top)
        }
        
        checkBtn.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().inset(20 + safeAreaInsets.bottom)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
