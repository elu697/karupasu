//
//  AppData.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import Foundation

/// Application data from Userdefaults
struct AppData {
    @UserDefault("firstLunch", default: true)
    var firstLunch: Bool
    
    @UserDefault("teamId", default: 0)
    var teamId: Int
    
    @UserDefault("userMailAddress", default: "")
    var userMailAddress: String
    
    @UserDefault("userName", default: "")
    var userName: String
    
    @UserDefault("userPassword", default: "")
    var userPassword: String
    
    @UserDefault("uid", default: "")
    var uid: String
    
    @UserDefault("userToken", default: "")
    var client: String
    
    @UserDefault("accessToken", default: "")
    var accessToken: String
    
    @UserDefault("roomIds", default: [])
    var roomIds: [Int]
    
    
    
    static func resetALL() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        keys.forEach(UserDefaults.standard.removeObject(forKey:))
    }
}
