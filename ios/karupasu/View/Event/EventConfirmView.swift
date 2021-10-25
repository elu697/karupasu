//
//  EventConfirmView.swift
//  karupasu
//
//  Created by El You on 2021/08/23.
//

import UIKit

class EventConfirmView: UIView {
    let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .appGray
        return view
    }()

    let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Title"
        lbl.font = .appFontBoldOfSize(22)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingMiddle
        return lbl
    }()

    let barView1: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()
    
    let memberTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.numberOfParticipants()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .black
        return lbl
    }()
    
    let memberLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "0"
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .appGray
        return lbl
    }()
    
    let barView2: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
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
        lbl.text = "None"
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .appGray
        return lbl
    }()
    
    let barView3: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
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
        lbl.text = "None"
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .appGray
        return lbl
    }()
    
    let barView4: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()
    
    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = AppText.memo()
        lbl.font = .appFontOfSize(11)
        lbl.textColor = .appTextGray
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    let fixBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appTextGray
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.fix(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        //        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        return btn
    }()
    
    let postBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appMain
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.post(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        //        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        return btn
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(thumbnailImage)
        addSubview(titleLbl)
        addSubview(barView1)
        addSubview(memberTitleLbl)
        addSubview(memberLbl)
        addSubview(barView2)
        addSubview(placeTitleLbl)
        addSubview(placeLbl)
        addSubview(barView3)
        addSubview(genreTitleLbl)
        addSubview(genreLbl)
        addSubview(barView4)
        addSubview(messageLbl)
        addSubview(fixBtn)
        addSubview(postBtn)
        initLayout()
    }

    func initLayout() {
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(snp.width).multipliedBy(0.64)
        }

        titleLbl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            //            make.height.equalTo(80)
            make.top.equalTo(thumbnailImage.snp.bottom).offset(16)
        }

        barView1.snp.makeConstraints { (make) in
            make.top.equalTo(titleLbl.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        memberTitleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(barView1.snp.bottom)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        memberLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(memberTitleLbl)
            make.right.equalToSuperview().inset(16)
        }

        barView2.snp.makeConstraints { (make) in
            make.top.equalTo(memberTitleLbl.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        placeTitleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(barView2.snp.bottom)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        placeLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(placeTitleLbl)
            make.right.equalToSuperview().inset(16)
        }
        
        barView3.snp.makeConstraints { (make) in
            make.top.equalTo(placeTitleLbl.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        genreTitleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(barView3.snp.bottom)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        genreLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(genreTitleLbl)
            make.right.equalToSuperview().inset(16)
        }
        
        barView4.snp.makeConstraints { (make) in
            make.top.equalTo(genreTitleLbl.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        messageLbl.snp.makeConstraints { (make) in
            make.top.equalTo(barView4.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        fixBtn.snp.makeConstraints { (make) in
            make.width.equalTo(164)
            make.height.equalTo(48)
            make.right.equalTo(snp.centerX).offset(-8)
            make.bottom.equalToSuperview().inset(20)
        }
        
        postBtn.snp.makeConstraints { (make) in
            make.width.equalTo(164)
            make.height.equalTo(48)
            make.left.equalTo(snp.centerX).offset(8)
            make.bottom.equalToSuperview().inset(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImage.snp.updateConstraints { (make) in
            make.top.equalTo(safeAreaInsets.top)
        }
        
        fixBtn.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().inset(20 +  safeAreaInsets.bottom)
        }
        
        postBtn.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().inset(20 +  safeAreaInsets.bottom)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
