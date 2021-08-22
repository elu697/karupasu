//
//  EventOptionSelectView.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import UIKit

class EventOptionSelectView: UIView {

    let optionTableView: UITableView = {
        let view = UITableView()
        return view
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
        addSubview(optionTableView)
        addSubview(confirmBtn)
        setupLayout()
    }

    private func setupLayout() {
        confirmBtn.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        optionTableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top).offset(-24)
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
