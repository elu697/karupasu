//
//  MemberTitileView.swift
//  karupasu
//
//  Created by El You on 2021/08/26.
//

import Foundation
import UIKit


class MemberTitleView: UIView {
    let prefectureLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "NONE"
        lbl.textColor = .appMain
        lbl.font = .appFontBoldOfSize(15)
//        lbl.autoresizesSubviews = true
//        lbl.autoresizingMask = .flexibleHeight
        lbl.textAlignment = .left
        return lbl
    }()

    let memberLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "NONE"
        lbl.textColor = .black
        lbl.font = .appFontBoldOfSize(14)
        lbl.textAlignment = .center

        return lbl
    }()

    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "NONE"
        lbl.textColor = .black
        lbl.font = .appFontOfSize(11)
        lbl.textAlignment = .left
        return lbl
    }()

    let openBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(AppImage.navi_back_gray(), for: .normal)
        btn.rotate(degrees: -90)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(prefectureLbl)
        addSubview(memberLbl)
        addSubview(messageLbl)
        addSubview(openBtn)
        setupLayout()
    }

    private func setupLayout() {

        prefectureLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(11)
            make.height.equalTo(24)
            make.left.equalToSuperview().inset(17)
            make.width.equalTo(48)
        }

        memberLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(11)
            make.height.equalTo(24)
            make.left.equalTo(prefectureLbl.snp.right).offset(10)
            make.width.equalTo(48)
        }

        messageLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(11)
            make.height.equalTo(24)
            make.left.equalTo(memberLbl.snp.right).offset(10)
        }

        openBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
            make.right.equalTo(-16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
