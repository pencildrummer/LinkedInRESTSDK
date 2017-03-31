//
//  LinkedInProfile.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Foundation
import ObjectMapper

open class LinkedInProfile: NSObject, Mappable {
    
    open fileprivate(set) var id: String!
    open fileprivate(set) var firstName: String!
    open fileprivate(set) var lastName: String!
    open fileprivate(set) var maidenName: String?
    open fileprivate(set) var formattedPhone: String?
    open fileprivate(set) var headline: String?
    
    open fileprivate(set) var publicProfileURL: URL?
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        
        headline <- map["headline"]
        
        publicProfileURL <- (map["publicProfileUrl"], URLTransform())
    }
    
}
