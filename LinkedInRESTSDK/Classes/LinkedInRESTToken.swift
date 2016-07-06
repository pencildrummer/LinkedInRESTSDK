//
//  LinkedInRESTToken.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Foundation

public class LinkedInRESTToken: NSObject, NSCoding {
    
    private static let kCurrentTokenKey = "com.fabioborella.pencildrummer.linkedinrest.current_token"
    static var currentToken: LinkedInRESTToken? {
        set {
            if let token = newValue {
                let tokenData = NSKeyedArchiver.archivedDataWithRootObject(token)
                NSUserDefaults.standardUserDefaults().setObject(tokenData, forKey: kCurrentTokenKey)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kCurrentTokenKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            if let tokenData = NSUserDefaults.standardUserDefaults().dataForKey(kCurrentTokenKey) {
                return NSKeyedUnarchiver.unarchiveObjectWithData(tokenData) as? LinkedInRESTToken
            }
            return nil
        }
    }
    
    public private(set) var accessToken: String!
    public private(set) var expiresIn: NSTimeInterval!
    /*public var isExpired: Bool {
        return NSDate().timeIntervalSince1970 - expiresIn > 0
    }*/
 
    init(JSON: [String: AnyObject]) {
        accessToken = JSON["access_token"] as! String
        expiresIn = NSTimeInterval(JSON["expires_in"] as! String)
    }
    
    // Coding
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        accessToken = aDecoder.decodeObjectForKey("accessToken") as! String
        expiresIn = aDecoder.decodeDoubleForKey("expiresIn")
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessToken, forKey: "accessToken")
        aCoder.encodeDouble(expiresIn, forKey: "expiresIn")
    }
}