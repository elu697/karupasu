//
//  FilterTableViewCell.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import Foundation
import UIKit


class FilterTableViewCell: UITableViewCell {
    let dummyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let checkOnView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = .appMain
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    
    let checkOffView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appTextGray.cgColor
        return view
    }()
    
    let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .appFontOfSize(14)
        lbl.textAlignment = .left
        lbl.text = "None"
        return lbl
    }()
    
    var isCheck: Bool = false {
        didSet {
            checkOffView.isHidden = isCheck
            checkOnView.isHidden = !isCheck
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectedBackgroundView = dummyView
        addSubview(checkOnView)
        addSubview(checkOffView)
        addSubview(titleLbl)
        setupLayout()
    }

    private func setupLayout() {
        checkOnView.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        checkOffView.snp.makeConstraints { (make) in
            make.edges.equalTo(checkOnView)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.left.equalTo(checkOnView.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.height.right.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        isCheck = selected
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
