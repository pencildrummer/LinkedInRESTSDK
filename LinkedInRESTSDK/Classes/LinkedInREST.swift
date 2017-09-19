//
//  LinkedInREST.swift
//  Pods
//
//  Created by Fabio Borella on 06/07/16.
//
//

import Alamofire
import AlamofireObjectMapper

open class LinkedInREST {
    
    open static var clientID: String!
    open static var clientSecret: String!
    open static var redirectURI: String!
    
    open class func getAccessToken(_ code: String, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        Alamofire.request(LinkedInRESTRouter.getAccessToken(code)).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
            case .success(let JSON):
                let token = LinkedInRESTToken(JSON: JSON as! [String: AnyObject])
                LinkedInRESTToken.currentToken = token
                
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    open class func getUserProfile(_ fields: [String]?, completion: @escaping (_ success: Bool, _ profile: LinkedInProfile?, _ error: Error?) -> ()) {
        getUserProfile(nil, fields: fields, completion: completion)
    }
    
    open class func getUserProfile(_ profileId: String?, fields: [String]?, completion: @escaping (_ success: Bool, _ profile: LinkedInProfile?, _ error: Error?) -> ()) {
        Alamofire.request(LinkedInRESTRouter.getUserProfile(profileId, fields)).validate(statusCode: 200..<300)
            .debugLog()
            .responseObject { (response: DataResponse<LinkedInProfile>) in
                response.debugLog()
            switch response.result {
            case .success(let profile):
                completion(true, profile, nil)
            case .failure(let error):
                completion(false, nil, error)
            }
        }
    }
    
}

extension Alamofire.Request {
    
    fileprivate func debugLog() -> Self {
        debugPrint(self)
        return self
    }
}

extension Alamofire.DataResponse {
    
    public func debugLog() {
        print("- RESPONSE -")
        debugPrint(self.response as Any)
        if let valueData = self.data {
            if let JSON = try? JSONSerialization.jsonObject(with: valueData, options: []),
                let JSONData = try? JSONSerialization.data(withJSONObject: JSON, options: [.prettyPrinted]),
                let prettyJSON = String(data: JSONData, encoding: String.Encoding.utf8) {
                print("Response raw body - JSON pretty:")
                print(prettyJSON)
            } else if let dataString = String(data: valueData, encoding: String.Encoding.utf8) {
                print("Response raw body:", dataString)
            }
        } else {
            debugPrint("Response raw body: EMPTY")
        }
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
        case .getUserProfile(_, let fields):
            var path = "people/~"
            if let fields = fields, fields.count > 0 {
                path = path + ":(\(fields.joined(separator: ",")))"
            }
            return path
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getAccessToken(_):
            return .get
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
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
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        
        var encoding: ParameterEncoding!
        
        // Configure return format
        
        if isAPI {
            
            encoding = Alamofire.URLEncoding.default
            
            request.setValue(LinkedInRESTRouter.format, forHTTPHeaderField: "x-li-format")
            
            // Configuration authorization header
            
            if let currentToken = LinkedInRESTToken.currentToken {
                request.setValue("Bearer \(currentToken.accessToken!)", forHTTPHeaderField: "Authorization")
            }
            
        } else {
            
            encoding = Alamofire.URLEncoding.default
            
        }
        
        return try encoding.encode(request, with: parameters)
    }
    
}
