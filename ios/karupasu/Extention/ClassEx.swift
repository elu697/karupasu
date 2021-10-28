//
//  ClassEx.swift
//  karupasu
//
//  Created by El You on 2021/08/29.
//

import Foundation

public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        String(describing: self)
    }
    
    var className: String {
        type(of: self).className
    }
}

extension NSObject: ClassNameProtocol { }

extension Array where Element: Hashable {
    func unique() -> Array {
        var hash = [Element : Bool]()
        return reduce([], { (array, element) in
            if hash[element] != nil { return array }
            hash[element] = true
            return array + [element]
        })
    }
}
