//
//  APISurveyProvider.swift
//  survey-list-app
//
//  Created by amnmblchllng on 24.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation
import Alamofire

class MockSurveyProvider: SurveyProvider {
    
    // getSurveys retrieves surveys from mock data; results can be paged optionally
    func getSurveys(page: Int? = nil, perPage: Int? = nil, completion: ((Error?, [Survey]?) -> ())? = nil) {
        var surveys: [Survey] = []
        for i in 1...50 {
            let survey = Survey(id: "id_\(i)", title: "title_\(i)", description: "desc_\(i)", coverImageUrl: "https://dummyimage.com/300/09f/fff.png?a=\(i)&b=k")
            surveys.append(survey)
        }
        let page = (page ?? 1) - 1
        let perPage = perPage ?? surveys.count
        let start = page * perPage
        let end = min(surveys.count, page * perPage + perPage)
        if (start > end) {
            completion?(nil, [])
        } else {
            let slice = surveys[start..<end]
            completion?(nil, Array(slice))
        }
    }
}

