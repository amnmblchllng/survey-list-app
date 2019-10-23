//
//  API.swift
//  survey-list-app
//
//  Created by amnmblchllng on 10.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation
import Alamofire

// API communicates with the survey API, does autorization and retrieves the list of surveys
class API {
    // see survey-list.xcconfig
    private let baseUrl = "https://\(Bundle.main.object(forInfoDictionaryKey:"API_BASE_URL") as! String)/"
    private let authUser = Bundle.main.object(forInfoDictionaryKey:"API_AUTH_USER") as! String
    private let authPass = Bundle.main.object(forInfoDictionaryKey:"API_AUTH_PASS") as! String
    
    // bearer token for auth
    private var bearer: Bearer?
    
    // getSurveys retrieves surveys from the API and handles authentication if needed; results can be paged optionally
    func getSurveys(page: Int? = nil, perPage: Int? = nil, completion: ((Error?, [Survey]?) -> ())? = nil) {
        authIfNeeded() { error, bearer in
            guard let bearer = bearer, error == nil else {
                completion?(error, nil)
                return
            }
            
            var params = [ "access_token": bearer.accessToken ]
            if let page = page {
                params["page"] = String(page)
            }
            if let perPage = page {
                params["per_page"] = String(perPage)
            }
            
            Alamofire.request("\(self.baseUrl)surveys.json", method: .get, parameters: params)
            .responseJSON { response in
                if let error = response.result.error {
                    // treat alamofire error as network error
                    completion?(NSError(domain: "api.surveys", code: errors.network.rawValue, userInfo: ["original": error]), nil)
                    return
                }
                guard let status = response.response?.statusCode, status == 200 else {
                    // treat response format problems as backend error
                    completion?(NSError(domain: "api.surveys", code: errors.backend.rawValue), nil)
                    return
                }
                
                // api responds sometimes with [] and sometimes with nil when page is empty
                let list = (response.result.value as? NSArray) ?? []
                
                // response is a list; parse the objects
                var surveys: [Survey] = []
                surveys.reserveCapacity(list.count)
                for elem in list {
                    guard
                        let s = elem as? NSDictionary,
                        let id = s["id"] as? String,
                        let title = s["title"] as? String,
                        let description = s["description"] as? String,
                        let coverImageUrl = s["cover_image_url"] as? String
                    else {
                        // treat response format problems as backend error
                        completion?(NSError(domain: "api.surveys", code: errors.backend.rawValue), nil)
                        return
                    }
                    surveys.append(Survey(id: id, title: title, description: description, coverImageUrl: coverImageUrl))
                }
                
                completion?(nil, surveys)
            }
        }
    }
    
    // response error codes
    enum errors: Int {
        case network = 1, backend
    }
    
    // Bearer has access token and expiration date
    struct Bearer {
        var accessToken: String
        var expirationDate: Date
        var expiredOrExpiresSoon: Bool {
            get {
                let soonSeconds = TimeInterval(60)
                let soonDate = Date().addingTimeInterval(soonSeconds)
                return soonDate > expirationDate
            }
        }
    }
    
    // authIfNeeded authorizes API if no token is available or if it expires soon.
    func authIfNeeded(completion: ((Error?, Bearer?) -> ())? = nil) {
        if bearer == nil || bearer?.expiredOrExpiresSoon == true {
            // we could add a semaphore in the future if we want to invalidate only once
            getNewBearer() { (error, bearer) in
                if error != nil {
                    completion?(error, nil)
                    return
                }
                self.bearer = bearer
                completion?(nil, bearer)
            }
        } else {
            completion?(nil, bearer)
        }
    }
    
    // getNewBearer returns a new bearer token from hard coded username and password
    func getNewBearer(completion: ((Error?, Bearer?)->())? = nil) {
        // get token
        let params = [
            "grant_type": "password",
            "username": authUser,
            "password": authPass,
        ]
        Alamofire.request("\(baseUrl)oauth/token", method: .post, parameters: params)
        .responseJSON { response in
            if let error = response.result.error {
                // treat alamofire error as network error
                completion?(NSError(domain: "api.auth", code: errors.network.rawValue, userInfo: ["original": error]), nil)
                return
            }
            
            guard
                let status = response.response?.statusCode, status == 200,
                let result = response.result.value,
                let json = result as? NSDictionary,
                let tokenType = json["token_type"] as? String, tokenType == "bearer",
                let accessToken = json["access_token"] as? String,
                let expiresIn = json["expires_in"] as? Int,
                let createdAt = json["created_at"] as? Int
            else {
                // treat response format problems as backend error
                completion?(NSError(domain: "auth", code: errors.backend.rawValue), nil)
                return
            }
            let expirationDate = Date(timeIntervalSince1970: TimeInterval(createdAt + expiresIn))
            let bearer = Bearer(accessToken: accessToken, expirationDate: expirationDate)
            
            completion?(nil, bearer)
        }
    }
    
}

