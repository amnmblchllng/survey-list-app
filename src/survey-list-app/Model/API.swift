//
//  API.swift
//  survey-list-app
//
//  Created by amnmblchllng on 10.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation
import Alamofire

// API provides access to the API and does auth
class API {
    // afSessionManager for auth providers
    let afSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    
    // see survey-list.xcconfig
    let baseUrl = "https://\(Bundle.main.object(forInfoDictionaryKey:"API_BASE_URL") as! String)/"
    private let authUser = Bundle.main.object(forInfoDictionaryKey:"API_AUTH_USER") as! String
    private let authPass = Bundle.main.object(forInfoDictionaryKey:"API_AUTH_PASS") as! String
    
    // bearer token for auth
    private var bearer: Bearer?
    
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
        self.afSessionManager.request("\(baseUrl)oauth/token", method: .post, parameters: params)
        .responseData { response in
            if let error = response.result.error {
                completion?(APIError.network(error), nil)
                return
            }
            
            guard
                let status = response.response?.statusCode, status == 200,
                let result = response.result.value,
                let bearer = try? JSONDecoder().decode(Bearer.self, from: result)
            else {
                // treat response format problems as backend error
                completion?(APIError.backend, nil)
                return
            }
            
            completion?(nil, bearer)
        }
    }
    
}

