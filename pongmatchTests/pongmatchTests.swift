//
//  pongmatchTests.swift
//  pongmatchTests
//
//  Created by Jordi Puigdellívol on 5/9/25.
//

import Testing
@testable import pongmatch

struct pongmatchTests {

    @Test func example() async throws {
        let result = try await Api.token(
            email: "jordi@gloobus.net",
            password: "supersecret",
            deviceName: "iOS Device"
        )
        
    }

}
