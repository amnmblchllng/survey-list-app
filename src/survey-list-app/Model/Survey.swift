//
//  Survey.swift
//  survey-list-app
//
//  Created by amnmblchllng on 10.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation

// Survey model from API that is used in the UI
struct Survey: Decodable {
    var id: String
    var title: String
    var description: String
    var coverImageUrl: String
    var coverImageUrlLarge: String {
        get {
            return "\(coverImageUrl)l"
        }
    }
    // ... more fields if needed
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case coverImageUrl = "cover_image_url"
    }
}
