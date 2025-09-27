//
//  TestResults.swift
//  pongmatchTests
//
//  Created by Jordi Puigdellívol on 27/9/25.
//

import Testing
@testable import pongmatch

@Suite("Set validation")
struct TestResultIsValid {
    
    @Test func validScores() {
        #expect(isValidSetScore(11, 0))
        #expect(isValidSetScore(11, 9))
        #expect(isValidSetScore(12, 10))
        #expect(isValidSetScore(15, 13))
    }

    @Test func invalidScores() {
        #expect(!isValidSetScore(11, 10))
        #expect(!isValidSetScore(12, 11))
        #expect(!isValidSetScore(12, 9))   // would have ended 11–9
        #expect(!isValidSetScore(10, 8))
        #expect(!isValidSetScore(0, 0))
        #expect(!isValidSetScore(10, 15))
    }

    private func isValidSetScore(_ a: Int, _ b: Int, target: Int = 11) -> Bool {
        Score.Result(a, b).isValid()
    }

}
