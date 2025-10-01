//
//  UserGetMeTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class UserGetMeTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }
    
    override func tearDown() async throws {
        try await UserData.query(on: app.db).delete()
        try? await app.asyncShutdown()
    }
    
    func testGetMeSuccessfully() throws {
        let login = "meuser_\(UUID())"
        let password = "password123"

        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        })

        var accessToken: String!
        var userId: UUID!
        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            let authResponse = try res.content.decode(JwtResponse.self)
            accessToken = authResponse.accessToken
            userId = try JwtProviderImpl(secret: "secret").getUserID(from: accessToken)
        }

        try app.test(.GET, "/user/me", headers: [
            "Authorization": "Bearer \(accessToken!)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(UserResponse.self)
            XCTAssertEqual(response.id, userId)
            XCTAssertEqual(response.login, login)
        }
    }
    
    func testUnauthorizedGetMe() throws {
        try app.test(.GET, "/user/me") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testResponseStructure() throws {
        let login = "structuser_\(UUID())"
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

        try app.test(.GET, "/user/me", headers: [
            "Authorization": "Bearer \(accessToken!)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(UserResponse.self)
            XCTAssertEqual(response.id, userId)
            XCTAssertEqual(response.login, login)
        }
    }
}

