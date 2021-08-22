//
//  EventApplyView.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import UIKit

class EventApplyView: UIView {
    
    let prefectureBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .appWhiteGray
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appGray.cgColor
        return view
    }()
    
    let prefectureTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.prefecture()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .black
        return lbl
    }()
    
    let prefectureLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.pleaseSelect()
        lbl.font = .appFontOfSize(14)
        lbl.textColor = .appGray
        return lbl
    }()
    
    let confirmBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appMain
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.confirm(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        //        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prefectureBaseView.addSubview(prefectureTitleLbl)
        prefectureBaseView.addSubview(prefectureLbl)
        addSubview(prefectureBaseView)
        addSubview(confirmBtn)
        setupLayout()
    }
    
    private func setupLayout() {
        prefectureBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        prefectureTitleLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(prefectureBaseView).inset(11)
            make.left.equalTo(prefectureBaseView).inset(16)
        }
        
        prefectureLbl.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(prefectureBaseView).inset(11)
            make.right.equalTo(prefectureBaseView).inset(16)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        confirmBtn.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().inset(20 + safeAreaInsets.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
