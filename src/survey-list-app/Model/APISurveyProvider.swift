//
//  APISurveyProvider.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation
import Alamofire

class APISurveyProvider: SurveyProvider {
    
    let api: API
    
    init(api: API) {
        self.api = api
    }
    
    // getSurveys retrieves surveys from the API and handles authentication if needed; results can be paged optionally
    func getSurveys(page: Int? = nil, perPage: Int? = nil, completion: ((Error?, [Survey]?) -> ())? = nil) {
        api.authIfNeeded() { error, bearer in
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
            
            self.api.afSessionManager.request("\(self.api.baseUrl)surveys.json", method: .get, parameters: params)
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
}
