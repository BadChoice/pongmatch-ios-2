//
//  pongmatchTests.swift
//  pongmatchTests
//
//  Created by Jordi Puigdellívol on 5/9/25.
//

import Testing
@testable import pongmatch

struct pongmatchTests {

    @Test func can_do_login_ok() async throws {
        let _ = try await Api.login(
            email: "jordi@gloobus.net",
            password: "supersecret",
            deviceName: "iOS Device"
        )
    }
    
    @Test func can_get_my_info() async throws {
        let user = try await Api("5|j4BFbA7SlGn6AEAl6bfxViD8DMKRnpV7mt5OkExC5e9ebd7d").me()
        
        #expect(user.name == "Jordi Puigdellívol")
    }
    
    @Test func can_do_login_fail() async throws {
        await #expect(throws: Api.Errors.self) {
            let _ = try await Api.login(
                email: "jordi@gloobus.net",
                password: "invalid_password",
                deviceName: "iOS Device"
            )
        }
    }
    
}
