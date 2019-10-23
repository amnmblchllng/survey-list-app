//
//  APIError.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation

// response error codes
enum APIError: Error {
    case network(Error?)
    case backend
}
