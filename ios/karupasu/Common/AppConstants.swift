//
//  AppConstants.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import Foundation
import UIKit

// Constants
struct AppConstants {
    struct Color {
        static let main = UIColor(hex: 0x00809E, alpha: 1.0)
        static let gray = UIColor(hex: 0xCDD3D4, alpha: 1.0)
        static let whiteGray = UIColor(hex: 0xF2F5F6, alpha: 1.0)
        static let textGray = UIColor(hex: 0x797E80, alpha: 1.0)
    }
    struct Font {
        static let main = "NotoSansJP-Regular"
        static let mailBold = "NotoSansJP-Bold"

    }
    struct Strage {
        static let base = "gs://much-match.appspot.com"
    }
    
    struct API {
        /// api base
//        static let base = "http://localhost:3001/\(v)"
        static let base = "http://mc.miraito.tech/\(v)"
        static let v = "v1"
    }
}
