//
//  MockTests.swift
//  survey-list-appTests
//
//  Created by amnmblchllng on 10.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import XCTest
@testable import survey_list_app

class MockTests: XCTestCase {
    
    var surveyProvider: SurveyProvider!
    
    override func setUp() {
        super.setUp()
        surveyProvider = MockSurveyProvider()
        continueAfterFailure = false
    }
    
    func testGetSurveys() {
        wait(for: [
            _testGetSurveys(),
            _testGetSurveys(page: 3, perPage: 10),
            _testGetSurveys(page: 4, perPage: 10),
            _testGetSurveys(page: 100, perPage: 100),
            ], timeout: 10.0)
    }
    
    func _testGetSurveys(page: Int? = nil, perPage: Int? = nil) -> XCTestExpectation {
        let ok = expectation(description: "got surveys")
        surveyProvider.getSurveys(page: page, perPage: perPage) { error, surveys in
            XCTAssertNil(error, "error not nil")
            XCTAssertNotNil(surveys, "surveys are nil")
            ok.fulfill()
        }
        return ok
    }
    
}



