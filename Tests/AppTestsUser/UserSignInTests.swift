//
//  UserSignInTests.swift
//  TicTacToe
//

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Di

final class UserSignInTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try? await app.asyncShutdown()
    }
    
    func testSignInSuccess() throws {
        let login = "newuser"
        let password = "somepassword"

        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let signUpResponse = try res.content.decode(UserIdResponse.self)
            XCTAssertNotNil(signUpResponse.id)
        }

        try app.test(.POST, "/signin") { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let jwtResponse = try res.content.decode(JwtResponse.self)
            XCTAssertEqual(jwtResponse.type, "Bearer")
            XCTAssertFalse(jwtResponse.accessToken.isEmpty)
            XCTAssertFalse(jwtResponse.refreshToken.isEmpty)
        }
    }

    func testSignInWrongLogin() throws {
        try app.test(.POST, "/signin") { req in
            try req.content.encode(JwtRequest(login: "unknownuser", password: "somepassword"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, UserError.invalidLoginOrPassword.reason)
        }
    }

    func testSignInWrongPassword() throws {
        let login = "testuser"
        let password = "correctPassword"

        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        }

        try app.test(.POST, "/signin") { req in
            try req.content.encode(JwtRequest(login: login, password: "wrongPassword"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, UserError.invalidLoginOrPassword.reason)
        }
    }

    func testSignInWithEmptyBody() throws {
        try app.test(.POST, "/signin", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: "{}")) { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertContains(res.body.string, "No such key 'login'")
        }
    }

    func testSignInWithMalformedBody() throws {
        let invalidJson = """
        {
          "login": "user"
        }
        """

        try app.test(.POST, "/signin", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: invalidJson)) { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertContains(res.body.string, "No such key 'password'")
        }
    }

}
