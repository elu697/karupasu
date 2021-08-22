//
//  FilterSectionHeaderView.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import Foundation
import UIKit


class FilterSectionHeaderView: UITableViewHeaderFooterView {
    let dummyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = .appFontBoldOfSize(18)
        lbl.backgroundColor = .white
        lbl.text = "none"
            return lbl
    }()


    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(dummyView)
        addSubview(titleLbl)
        setupLayout()
    }

    private func setupLayout() {
        dummyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(13)
            make.centerX.left.right.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
