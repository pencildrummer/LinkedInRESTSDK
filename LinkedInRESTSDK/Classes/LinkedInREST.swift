//
//  LinkedInREST.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Alamofire
import AlamofireObjectMapper

public class LinkedInREST {
    
    public static var clientID: String!
    public static var clientSecret: String!
    public static var redirectURI: String!
    
    public class func getAccessToken(code: String, completion: (success: Bool, error: NSError?) -> ()) {
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
    
    public class func getUserProfile(fields: [String]?, completion: (success: Bool, profile: LinkedInProfile?, error: NSError?) -> ()) {
        getUserProfile(nil, fields: fields, completion: completion)
    }
    
    public class func getUserProfile(profileId: String?, fields: [String]?, completion: (success: Bool, profile: LinkedInProfile?, error: NSError?) -> ()) {
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
    
    private func debugLog() -> Self {
        //debugPrint(self)
        return self
    }
}

enum LinkedInRESTRouter: URLRequestConvertible {
    
    static var format: String? = "json"
    
    case GetAccessToken(String)
    
    case GetUserProfile(String?, [String]?)
    
    var isAPI: Bool {
        switch self {
        case .GetAccessToken(_):
            return false
        default:
            return true
        }
    }
    
    var baseURL: NSURL {
        switch self {
        case .GetAccessToken(_):
            return NSURL(string: "https://www.linkedin.com/")!
        default:
            return NSURL(string: "https://api.linkedin.com/v1/")!
        }
    }
    
    var path: String {
        switch self {
        case .GetAccessToken(_):
            return "oauth/v2/accessToken"
        case .GetUserProfile(let profileId, let fields):
            var path = "people/~"
            if fields?.count > 0 {
                path = path.stringByAppendingString(":(\(fields!.joinWithSeparator(",")))")
            }
            return path
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .GetAccessToken(_):
            return .GET
        default:
            return .GET
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .GetAccessToken(let code):
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
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent(path)!)
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
