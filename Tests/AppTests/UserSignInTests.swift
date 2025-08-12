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
        let base64 = Data("\(login):\(password)".utf8).base64EncodedString()
        try app.test(.POST, "/signup") { req in
            try req.content.encode(SignUpRequest(login, password))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .created)
        }
        try app.test(.POST, "/signin", headers: [
            "Authorization": "Basic \(base64)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

    
    func testSignInWrongLogin() throws {
        let mock = MockUserRepository(
            getByLoginHandler: { _ in nil }
        )
        app.userRepository = mock

        try app.test(.POST, "/signin") { req in
            try req.content.encode(SignUpRequest("unknownuser", "somepassword"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, GameError.invalidAuthorizedUser.reason)
        }
    }

    func testSignInWrongPassword() throws {
        let testUser = UserDomain(id: UUID(), login: "testuser", password: "correctPassword123")

        let mock = MockUserRepository(
            getByLoginHandler: { _ in testUser }
        )
        app.userRepository = mock

        try app.test(.POST, "/signin") { req in
            try req.content.encode(SignUpRequest("testuser", "wrongPassword"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, GameError.invalidAuthorizedUser.reason)
        }
    }

    func testSignInWithEmptyBody() throws {
        try app.test(.POST, "/signin", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: "{}")) { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, GameError.invalidAuthorizedUser.reason)
        }
    }

    func testSignInWithMalformedBody() throws {
        let invalidJson = """
        {
          "login": "user"
        }
        """

        try app.test(.POST, "/signin", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: invalidJson)) { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, GameError.invalidAuthorizedUser.reason)
        }
    }
}
