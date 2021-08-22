//
//  StringEx.swift
//  karupasu
//
//  Created by El You on 2021/08/30.
//

import Foundation
import CryptoKit

extension String {
    public func md5() -> String {
        let hash = Insecure.MD5.hash(data: self.data(using: .utf8) ?? .init())
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
