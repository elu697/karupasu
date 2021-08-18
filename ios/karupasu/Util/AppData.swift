//
//  AppData.swift
//  WagesCounter
//
//  Created by El You on 2021/05/22.
//

import Foundation
import UIKit
import CoreData

///https://gist.github.com/ryotapoi/5746c5e1103014efcea22cb026bbcd3f

// UserDefaults
extension UserDefaults {
    public func value<Value : UserDefaultCompatible>(type: Value.Type = Value.self, forKey key: String, default defaultValue: Value) -> Value {
        guard let object = object(forKey: key) else { return defaultValue }
        return Value(userDefaultObject: object) ?? defaultValue
    }
    public func setValue<Value : UserDefaultCompatible>(_ value: Value, forKey key: String) {
        set(value.toUserDefaultObject(), forKey: key)
    }
}

// UserDefaultsに保存可能な値
public protocol UserDefaultCompatible {
    init?(userDefaultObject: Any)
    func toUserDefaultObject() -> Any?
}

extension UserDefaultCompatible where Self : Codable {
    public init?(userDefaultObject: Any) {
        guard let data = userDefaultObject as? Data else { return nil }
        do {
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }
    public func toUserDefaultObject() -> Any? {
        try? JSONEncoder().encode(self)
    }
}

extension UserDefaultCompatible where Self : NSObject, Self : NSCoding {
    public init?(userDefaultObject: Any) {
        guard let data = userDefaultObject as? Data else { return nil }
        if let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Self {
            self = value
        } else {
            return nil
        }
    }
    public func toUserDefaultObject() -> Any? {
        if let object = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) {
            return object
        } else {
            return nil
        }
    }
}

extension Array : UserDefaultCompatible where Element : UserDefaultCompatible {
    private struct UserDefaultCompatibleError : Error {}
    public init?(userDefaultObject: Any) {
        guard let objects = userDefaultObject as? [Any] else { return nil }
        do {
            let values = try objects.map { (object: Any) -> Element in
                if let element = Element(userDefaultObject: object) {
                    return element
                } else {
                    throw UserDefaultCompatibleError()
                }
            }
            self = values
        } catch {
            return nil
        }
    }
    public func toUserDefaultObject() -> Any? {
        map { $0.toUserDefaultObject() }
    }
}

extension Dictionary : UserDefaultCompatible where Key == String, Value : UserDefaultCompatible {
    private struct UserDefaultCompatibleError : Swift.Error {}
    public init?(userDefaultObject: Any) {
        guard let objects = userDefaultObject as? [String: Any] else { return nil }
        do {
            let values = try objects.mapValues { object -> Value in
                if let value = Value(userDefaultObject: object) {
                    return value
                } else {
                    throw UserDefaultCompatibleError()
                }
            }
            self = values
        } catch {
            return nil
        }
    }
    
    public func toUserDefaultObject() -> Any? {
        mapValues { $0.toUserDefaultObject() }
    }
}

extension Optional : UserDefaultCompatible where Wrapped : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        self = Wrapped(userDefaultObject: userDefaultObject)
    }
    public func toUserDefaultObject() -> Any? {
        flatMap { $0.toUserDefaultObject() }
    }
}

extension Int : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

extension Double : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

extension Float : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

extension Bool : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

extension String : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

extension URL : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Data else { return nil }
        guard let url = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(userDefaultObject) as? URL else { return nil }
        self = url
    }
    public func toUserDefaultObject() -> Any? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension Date : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

extension Data : UserDefaultCompatible {
    public init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }
    public func toUserDefaultObject() -> Any? {
        self
    }
}

// Property Wrapper
@propertyWrapper
public struct UserDefault<Value : UserDefaultCompatible> {
    private let key: String
    private let defaultValue: Value
    
    public init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value {
        get {
            UserDefaults.standard.value(type: Value.self, forKey: key, default: defaultValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

struct AppData {
    @UserDefault("currentTime", default: 0)
    var currentTime: Double
    
    @UserDefault("wage", default: 0)
    var wage: Double
    
    @UserDefault("hwage", default: 900)
    var hwage: Int
    
    static func resetALL() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        keys.forEach(UserDefaults.standard.removeObject(forKey:))
    }
}

/**
 // Test Code
 struct User : Codable, UserDefaultCompatible {
 var name: String
 }
 
 class Record : NSObject, NSCoding, UserDefaultCompatible {
 var name: String? = "abc"
 
 init(name: String?) {
 self.name = name
 }
 required init?(coder: NSCoder) {
 name = coder.decodeObject(forKey: "name") as? String
 }
 
 func encode(with coder: NSCoder) {
 coder.encode(name, forKey: "name")
 }
 }
 
 struct Settings {
 
 @UserDefault("user", default: User(name: "abc"))
 var user: User
 
 @UserDefault("userOptional", default: nil)
 var userOptional: User?
 
 @UserDefault("users", default: [])
 var users: [User]
 
 @UserDefault("userArrayOptional", default: nil)
 var userArrayOptional: [User]?
 
 @UserDefault("userDictionary", default: [:])
 var userDictionary: [String: User]
 
 @UserDefault("userDictionaryOptional", default: nil)
 var userDictionaryOptional: [String: User]?
 
 @UserDefault("int", default: 5)
 var int: Int
 
 @UserDefault("intOptional", default: nil)
 var intOptional: Int?
 
 @UserDefault("doubleValue", default: 23.56)
 var doubleValue: Double
 
 @UserDefault("doubleValueOptional", default: nil)
 var doubleValueOptional: Double?
 
 @UserDefault("floatValue", default: 1.23)
 var floatValue: Float
 
 @UserDefault("floatValueOptional", default: nil)
 var floatValueOptional: Float?
 
 @UserDefault("bool", default: true)
 var bool: Bool
 
 @UserDefault("boolOptional", default: nil)
 var boolOptional: Bool?
 
 @UserDefault("string", default: "defaultString")
 var string: String
 
 @UserDefault("stringOptional", default: nil)
 var stringOptional: String?
 
 @UserDefault("url", default: URL(string: "https://google.com")!)
 var url: URL
 
 @UserDefault("urlOptional", default: nil)
 var urlOptional: URL?
 
 @UserDefault("date", default: Date(timeIntervalSinceReferenceDate: 0))
 var date: Date
 
 @UserDefault("dateOptional", default: nil)
 var dateOptional: Date?
 
 @UserDefault("data", default: Data())
 var data: Data
 
 @UserDefault("dataOptional", default: nil)
 var dataOptional: Data?
 
 @UserDefault("record", default: Record(name: "default record name"))
 var record: Record
 
 @UserDefault("recordOptional", default: nil)
 var recordOptional: Record?
 
 }
 
 let keys = UserDefaults.standard.dictionaryRepresentation().keys
 keys.forEach(UserDefaults.standard.removeObject(forKey:))
 
 var settings = Settings()
 
 settings.user
 settings.user = User(name: "change name")
 */
