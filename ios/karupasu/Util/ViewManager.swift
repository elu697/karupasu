//
//  ViewManager.swift
//  karupasu
//
//  Created by El You on 2021/08/23.
//

import Foundation
import UIKit

struct ViewManager {
    
    static let rootViewController = UIApplication.shared.keyWindow?.rootViewController
    
    static let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    
    static var currentWindow: UIWindow? {
        if let window = UIApplication.shared.keyWindow {
            return window
        } else {
            return UIApplication.shared.windows[0] as? UIWindow
        }
    }
    
    // デフォルトFloat(44)としてUnwrap
    static func navigationBarHeight(callFrom: UIViewController?) -> CGFloat {
        return callFrom?.navigationController?.navigationBar.frame.size.height ?? 44
    }
}
