//
//  LinkedInProfile.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Foundation
import ObjectMapper

public class LinkedInProfile: NSObject, Mappable {
    
    public private(set) var id: String!
    public private(set) var firstName: String!
    public private(set) var lastName: String!
    public private(set) var maidenName: String?
    public private(set) var formattedPhone: String?
    public private(set) var headline: String?
    
    public private(set) var publicProfileURL: NSURL?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        
        headline <- map["headline"]
        
        publicProfileURL <- (map["publicProfileUrl"], URLTransform())
    }
    
}