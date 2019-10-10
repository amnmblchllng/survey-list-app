//
//  APITests.swift
//  survey-list-appTests
//
//  Created by amnmblchllng on 10.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import XCTest
@testable import survey_list_app

class APITests: XCTestCase {
    
    var api: API!
    override func setUp() {
        super.setUp()
        api = API()
        continueAfterFailure = false
    }
    
    func testGetSurveys() {
        let ok = self.expectation(description: "got surveys")
        api.getSurveys() { error, surveys in
            XCTAssertNil(error, "error not nil")
            XCTAssertNotNil(surveys, "surveys are nil")
            ok.fulfill()
        }
        self.wait(for: [ok], timeout: 5.0)
    }
    
    func testTokenExpiresSoon() {
        var bearer = API.Bearer(accessToken: "", expirationDate: Date())
        
        bearer.expirationDate = Date().addingTimeInterval(65)
        XCTAssertFalse(bearer.expiredOrExpiresSoon)

        bearer.expirationDate = Date().addingTimeInterval(55)
        XCTAssertTrue(bearer.expiredOrExpiresSoon)
        
        bearer.expirationDate = Date().addingTimeInterval(10000)
        XCTAssertFalse(bearer.expiredOrExpiresSoon)
        
        bearer.expirationDate = Date().addingTimeInterval(-65)
        XCTAssertTrue(bearer.expiredOrExpiresSoon)
    }
    
    func testAuthIfNeeded() {
        let ok = self.expectation(description: "auth ok")
        api.authIfNeeded() { error, bearer1 in
            XCTAssertNil(error, "error not nil")
            self.api.authIfNeeded() { error, bearer2 in
                XCTAssertNil(error, "error not nil")
                XCTAssertEqual(bearer1!.accessToken, bearer2!.accessToken, "tokens must be equal since re-auth is not needed yet")
                ok.fulfill()
            }
        }
        self.wait(for: [ok], timeout: 5.0)
    }
    
    func testAuth() {
        let authOk = self.expectation(description: "auth ok")
        api.getNewBearer() { (error, bearer) in
            XCTAssertNil(error, "error not nil")
            XCTAssertNotNil(bearer, "bearer is nil")
            XCTAssert(bearer!.expirationDate > Date(), "expiration date must be > date")
            authOk.fulfill()
        }
        self.wait(for: [authOk], timeout: 5.0)
    }
    
}


