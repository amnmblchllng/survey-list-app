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
    private let afSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    
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
            
            self.afSessionManager.request("\(self.baseUrl)surveys.json", method: .get, parameters: params)
            .responseData { response in
                if let error = response.result.error {
                    // treat alamofire error as network error
                    completion?(APIError.network(error), nil)
                    return
                }
                guard let status = response.response?.statusCode, status == 200 else {
                    // treat response format problems as backend error
                    completion?(APIError.backend, nil)
                    return
                }
                
                do {
                    guard let result = response.result.value else {
                        throw APIError.backend
                    }
                    // api responds sometimes with null and sometimes with [] when page is empty.
                    // so we check for null here. optional JSONDecoder [Survey]?.self doesn't suffice
                    if "null" == String(data: result, encoding: .utf8) {
                        completion?(nil, [])
                    } else {
                        completion?(nil, try JSONDecoder().decode([Survey].self, from: result))
                    }
                } catch {
                    completion?(error, nil)
                }
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

