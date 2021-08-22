//
//  MemberDetailView.swift
//  karupasu
//
//  Created by El You on 2021/08/26.
//

import Foundation
import UIKit


class MemberDetailView: UIView {
    let membersTextView: UITextView = {
        let view = UITextView()
        view.font = .appFontOfSize(11)
        view.textAlignment = .left
        view.text = "User\nUser\nUser"
        view.isScrollEnabled = false
        view.sizeToFit()
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets(top: 0, left: 17, bottom: 10, right: 10)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        view.attributedText = NSAttributedString(string: view.text,
                                                     attributes: attributes)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(membersTextView)
        setupLayout()
    }
    
    private func setupLayout() {
        membersTextView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

