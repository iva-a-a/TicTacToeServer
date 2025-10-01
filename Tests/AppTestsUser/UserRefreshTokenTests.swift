//
//  UserRefreshTokenTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class UserRefreshTokenTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try await UserData.query(on: app.db).delete()
        try? await app.asyncShutdown()
    }

    func testRefreshAccessTokenSuccess() throws {
        let login = "user_\(UUID())"
        let password = "pass123"

        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }

        var refreshToken: String!
        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let jwtResponse = try res.content.decode(JwtResponse.self)
            refreshToken = jwtResponse.refreshToken
        }

        try app.test(.POST, "/token/refresh-access", beforeRequest: { req in
            try req.content.encode(RefreshJwtRequest(refreshToken: refreshToken))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let jwtResponse = try res.content.decode(JwtResponse.self)
            XCTAssertFalse(jwtResponse.accessToken.isEmpty)
            XCTAssertEqual(jwtResponse.refreshToken, refreshToken) // refresh должен остаться прежним
        }
    }

    func testRefreshAccessTokenInvalidToken() throws {
        let invalidToken = "invalid.refresh.token"

        try app.test(.POST, "/token/refresh-access", beforeRequest: { req in
            try req.content.encode(RefreshJwtRequest(refreshToken: invalidToken))
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertContains(res.body.string, AuthenticationError.invalidRefreshToken.reason)
        }
    }

    func testRefreshRefreshTokenSuccess() throws {
        let login = "user_\(UUID())"
        let password = "pass123"

        try app.test(.POST, "/signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }

        var refreshToken: String!
        try app.test(.POST, "/signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let jwtResponse = try res.content.decode(JwtResponse.self)
            refreshToken = jwtResponse.refreshToken
        }

        try app.test(.POST, "/token/refresh-refresh", beforeRequest: { req in
            try req.content.encode(RefreshJwtRequest(refreshToken: refreshToken))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let jwtResponse = try res.content.decode(JwtResponse.self)
            XCTAssertFalse(jwtResponse.accessToken.isEmpty)
            XCTAssertNotEqual(jwtResponse.refreshToken, refreshToken) // refresh должен измениться
        }
    }

    func testRefreshRefreshTokenInvalidToken() throws {
        let invalidToken = "invalid.refresh.token"

        try app.test(.POST, "/token/refresh-refresh", beforeRequest: { req in
            try req.content.encode(RefreshJwtRequest(refreshToken: invalidToken))
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertContains(res.body.string, AuthenticationError.invalidRefreshToken.reason)
        }
    }
}
