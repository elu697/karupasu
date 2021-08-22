//
//  EventGenreCollectionReusableView.swift
//  karupasu
//
//  Created by El You on 2021/08/20.
//

import UIKit

class EventGenreCollectionReusableView: UICollectionReusableView {
    let genreLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "ジャンル: 映画 オンライン"
        lbl.font = .appFontBoldOfSize(14)
        lbl.textAlignment = .left
        lbl.textColor = .appMain
        lbl.backgroundColor = .clear
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(genreLbl)
        initLayout()
    }
    
    func initLayout() {
        genreLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
