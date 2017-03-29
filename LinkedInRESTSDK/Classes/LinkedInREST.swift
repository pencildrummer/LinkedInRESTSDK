//
//  LinkedInREST.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Alamofire
import AlamofireObjectMapper
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class LinkedInREST {
    
    open static var clientID: String!
    open static var clientSecret: String!
    open static var redirectURI: String!
    
    open class func getAccessToken(_ code: String, completion: (success: Bool, error: NSError?) -> ()) {
        Alamofire.request(LinkedInRESTRouter.GetAccessToken(code)).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
            case .Success(let JSON):
                let token = LinkedInRESTToken(JSON: JSON as! [String: AnyObject])
                LinkedInRESTToken.currentToken = token
                
                completion(success: true, error: nil)
            case .Failure(let error):
                completion(success: false, error: error)
            }
        }
    }
    
    open class func getUserProfile(_ fields: [String]?, completion: (success: Bool, profile: LinkedInProfile?, error: NSError?) -> ()) {
        getUserProfile(nil, fields: fields, completion: completion)
    }
    
    open class func getUserProfile(_ profileId: String?, fields: [String]?, completion: (success: Bool, profile: LinkedInProfile?, error: NSError?) -> ()) {
        Alamofire.request(LinkedInRESTRouter.GetUserProfile(profileId, fields)).validate(statusCode: 200..<300).responseObject { (response: Response<LinkedInProfile, NSError>) in
            switch response.result {
            case .Success(let profile):
                completion(success: true, profile: profile, error: nil)
            case .Failure(let error):
                completion(success: false, profile: nil, error: error)
            }
        }
    }
    
}

extension Request {
    
    fileprivate func debugLog() -> Self {
        //debugPrint(self)
        return self
    }
}

enum LinkedInRESTRouter: URLRequestConvertible {
    
    static var format: String? = "json"
    
    case getAccessToken(String)
    
    case getUserProfile(String?, [String]?)
    
    var isAPI: Bool {
        switch self {
        case .getAccessToken(_):
            return false
        default:
            return true
        }
    }
    
    var baseURL: URL {
        switch self {
        case .getAccessToken(_):
            return URL(string: "https://www.linkedin.com/")!
        default:
            return URL(string: "https://api.linkedin.com/v1/")!
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken(_):
            return "oauth/v2/accessToken"
        case .getUserProfile(let profileId, let fields):
            var path = "people/~"
            if fields?.count > 0 {
                path = path + ":(\(fields!.joined(separator: ",")))"
            }
            return path
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getAccessToken(_):
            return .GET
        default:
            return .GET
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .getAccessToken(let code):
            return [
                "grant_type" : "authorization_code",
                "code" : code,
                "redirect_uri" : LinkedInREST.redirectURI,
                "client_id" : LinkedInREST.clientID,
                "client_secret" : LinkedInREST.clientSecret
            ]
        default:
            return nil
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let request: NSMutableURLRequest = NSMutableURLRequest(url: baseURL.appendingPathComponent(path)!)
        request.HTTPMethod = method.rawValue
        
        // Configure return format
        
        if isAPI {
            request.setValue(LinkedInRESTRouter.format, forHTTPHeaderField: "x-li-format")
            
            // Configuration authorization header
            
            if let currentToken = LinkedInRESTToken.currentToken {
                request.setValue("Bearer \(currentToken.accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        // Configure parameters
        
        return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
    }
    
}
