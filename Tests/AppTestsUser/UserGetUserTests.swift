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
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let signUpResponse = try res.content.decode(UserIdResponse.self)
            XCTAssertNotNil(signUpResponse.id)
        }

        var userId: UUID!
        var accessToken: String!
        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let authResponse = try res.content.decode(JwtResponse.self)
            accessToken = authResponse.accessToken
            userId = try JwtProviderImpl(secret: "secret").getUserID(from: accessToken)
        }

        try app.test(.GET, "/user/\(userId!)", headers: [
            "Authorization": "Bearer \(accessToken!)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(UserResponse.self)
            XCTAssertEqual(user.id, userId)
            XCTAssertEqual(user.login, login)
        }
    }
    
    func testGetNonExistentUser() throws {
        let login = "user_\(UUID())"
        let password = "password123"

        var accessToken: String!
        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        })
        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            let authResponse = try res.content.decode(JwtResponse.self)
            accessToken = authResponse.accessToken
        }

        try app.test(.GET, "/user/\(UUID())", headers: [
            "Authorization": "Bearer \(accessToken!)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testGetUserWithInvalidId() throws {
        let login = "user_\(UUID())"
        let password = "password123"

        var accessToken: String!
        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        })
        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            let authResponse = try res.content.decode(JwtResponse.self)
            accessToken = authResponse.accessToken
        }

        try app.test(.GET, "/user/invalid-id", headers: [
            "Authorization": "Bearer \(accessToken!)"
        ]) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUnauthorizedAccess() throws {
        try app.test(.GET, "/user/\(UUID())") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testResponseStructure() throws {
        let login = "user_\(UUID())"
        let password = "password123"

        var accessToken: String!
        var userId: UUID!

        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        })

        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            let authResponse = try res.content.decode(JwtResponse.self)
            accessToken = authResponse.accessToken
            userId = try JwtProviderImpl(secret: "secret").getUserID(from: accessToken)
        }

        try app.test(.GET, "/user/\(userId!)", headers: [
            "Authorization": "Bearer \(accessToken!)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(UserResponse.self)
            XCTAssertEqual(response.id, userId)
            XCTAssertEqual(response.login, login)
        }
    }
}
