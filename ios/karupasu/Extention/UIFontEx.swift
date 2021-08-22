//
//  UIFontEx.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import Foundation
import UIKit

extension UIFont {
    class func appFontOfSize(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: AppConstants.Font.main, size: size) {
            return font
        }
        return systemFont(ofSize: size)
    }
    
    class func appFontBoldOfSize(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: AppConstants.Font.mailBold, size: size) {
            return font
        }
        return systemFont(ofSize: size)
    }
}
