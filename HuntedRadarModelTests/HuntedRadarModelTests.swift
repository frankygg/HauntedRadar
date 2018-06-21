//
//  HuntedRadarModelTests.swift
//  HuntedRadarModelTests
//
//  Created by BoTingDing on 2018/6/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import XCTest
@testable import HuntedRadar


class HuntedRadarModelTests: XCTestCase {
    
    var dbManager: DLManager!
    
    override func setUp() {
        super.setUp()
        dbManager = DLManager()
        
        
        
    }
    
    override func tearDown() {
        
        dbManager = nil
        super.tearDown()
    }
    
    func test_NumberOfDL_IsCorrect() {
        
        var dlDictionaries: [String: [String]]?

        let promise = expectation(description: "In the closure")
        
        dbManager.requestDLinJson(completion: { dlDictionariesInClosure in
            dlDictionaries = dlDictionariesInClosure
            promise.fulfill()
        })
        // 3
        waitForExpectations(timeout: 5, handler: nil)
        
        
        XCTAssertEqual(dlDictionaries?.count, 359)
       
    }
    
}
