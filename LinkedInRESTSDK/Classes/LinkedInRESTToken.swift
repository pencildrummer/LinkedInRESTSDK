//
//  LinkedInRESTToken.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Foundation

open class LinkedInRESTToken: NSObject, NSCoding {
    
    fileprivate static let kCurrentTokenKey = "com.fabioborella.pencildrummer.linkedinrest.current_token"
    static var currentToken: LinkedInRESTToken? {
        set {
            if let token = newValue {
                let tokenData = NSKeyedArchiver.archivedData(withRootObject: token)
                UserDefaults.standard.set(tokenData, forKey: kCurrentTokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kCurrentTokenKey)
            }
            UserDefaults.standard.synchronize()
        }
        get {
            if let tokenData = UserDefaults.standard.data(forKey: kCurrentTokenKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: tokenData) as? LinkedInRESTToken
            }
            return nil
        }
    }
    
    open fileprivate(set) var accessToken: String!
    open fileprivate(set) var expiresIn: TimeInterval!
    /*public var isExpired: Bool {
        return NSDate().timeIntervalSince1970 - expiresIn > 0
    }*/
 
    init(JSON: [String: AnyObject]) {
        accessToken = JSON["access_token"] as! String
        expiresIn = TimeInterval(JSON["expires_in"] as! String)
    }
    
    // Coding
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        accessToken = aDecoder.decodeObject(forKey: "accessToken") as! String
        expiresIn = aDecoder.decodeDouble(forKey: "expiresIn")
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(accessToken, forKey: "accessToken")
        aCoder.encode(expiresIn, forKey: "expiresIn")
    }
}
