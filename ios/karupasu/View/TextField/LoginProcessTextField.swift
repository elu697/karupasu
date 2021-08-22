//
//  LoginProcessTextField.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import Foundation
import UIKit

final class LoginProcessTextField: PaddingTextField {
    
    init(placeHolderText: String) {
        super.init(frame: .zero)
        textAlignment = .left
        font = .appFontOfSize(14)
        textColor = .darkText
        contentHorizontalAlignment = .center
        backgroundColor = .white
        autocorrectionType = .no
        autocapitalizationType = .none
        attributedPlaceholder = NSAttributedString(string: placeHolderText,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.appGray])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
