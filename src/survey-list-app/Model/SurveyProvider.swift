//
//  SurveyProvider.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation

protocol SurveyProvider {
    func getSurveys(page: Int?, perPage: Int?, completion: ((Error?, [Survey]?) -> ())?)
}
