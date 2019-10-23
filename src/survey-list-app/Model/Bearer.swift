//
//  Bearer.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import Foundation

extension API {
    // Bearer has access token and expiration date
    struct Bearer: Decodable {
        var accessToken: String
        var expirationDate: Date
        var expiredOrExpiresSoon: Bool {
            get {
                let soonSeconds = TimeInterval(60)
                let soonDate = Date().addingTimeInterval(soonSeconds)
                return soonDate > expirationDate
            }
        }
        
        init(accessToken: String, expirationDate: Date) {
            self.accessToken = accessToken
            self.expirationDate = expirationDate
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            accessToken = try values.decode(String.self, forKey: .access_token)
            guard let tokenType = try? values.decode(String.self, forKey: .token_type), tokenType == "bearer" else {
                throw DecodingError.dataCorruptedError(forKey: .token_type, in: values, debugDescription: "token_type must be 'bearer'")
            }
            let createdAt = try values.decode(Int.self, forKey: .created_at)
            let expiresIn = try values.decode(Int.self, forKey: .expires_in)
            expirationDate = Date(timeIntervalSince1970: TimeInterval(createdAt + expiresIn))
        }
        
        private enum CodingKeys: CodingKey {
            case access_token, token_type, expires_in, created_at
        }
    }
}
