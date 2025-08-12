//
//  UserGetUserTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class UserGetTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }
    
    override func tearDown() async throws {
        try await UserData.query(on: app.db).delete()
        try? await app.asyncShutdown()
    }
    
    func testGetExistingUser() throws {
        let login = "testuser_\(UUID())"
        let password = "testpassword"

        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(SignUpRequest(login, password))
        }) { res in
            XCTAssertEqual(res.status, .created)
        }

        var userId: UUID!
        let credentials = "\(login):\(password)".data(using: .utf8)!.base64EncodedString()
        try app.test(.POST, "/signin", headers: ["Authorization": "Basic \(credentials)"]) { res in
            XCTAssertEqual(res.status, .ok)
            let authResponse = try res.content.decode(UserAuthResponse.self)
            userId = authResponse.userId
        }
        app.middleware.use(AuthorizedUser.testMiddleware())

        try app.test(.GET, "/user/\(userId!)") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(UserResponse.self)
            XCTAssertEqual(user.id, userId)
            XCTAssertEqual(user.login, login)
        }
    }
    
    func testGetNonExistentUser() throws {
        let nonExistentUserId = UUID()
        
        app.middleware.use(AuthorizedUser.testMiddleware())
        try app.test(.GET, "/user/\(nonExistentUserId)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testGetUserWithInvalidId() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())
        try app.test(.GET, "/user/invalid-id") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUnauthorizedAccess() throws {
        let testUserId = UUID()
        try app.test(.GET, "/user/\(testUserId)") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testResponseStructure() throws {
        let login = "testuser_\(UUID())"
        let password = "password123"

        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(SignUpRequest(login, password))
        }) { res in
            XCTAssertEqual(res.status, .created)
        }

        var userId: UUID!
        let credentials = "\(login):\(password)".data(using: .utf8)!.base64EncodedString()
        try app.test(.POST, "/signin", headers: ["Authorization": "Basic \(credentials)"]) { res in
            XCTAssertEqual(res.status, .ok)
            let authResponse = try res.content.decode(UserAuthResponse.self)
            userId = authResponse.userId
        }
        app.middleware.use(AuthorizedUser.testMiddleware())

        try app.test(.GET, "/user/\(userId!)") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(UserResponse.self)
            XCTAssertEqual(response.id, userId)
            XCTAssertEqual(response.login, login)
        }
    }
}
