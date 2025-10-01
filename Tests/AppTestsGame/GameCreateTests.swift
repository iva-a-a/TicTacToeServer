//
//  GameCreateTests.swift
//  TicTacToe
//

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class GameCreateTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try? await app.asyncShutdown()
    }

    func testCreateGameWithAI() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "Alice", playWithAI: true))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameWeb.self)
            XCTAssertEqual(response.players.count, 2)
            XCTAssertEqual(response.state, .playerTurn(playerId))
        })
    }

    func testCreateGameWithoutAI() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "Bob", playWithAI: false))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameWeb.self)
            XCTAssertEqual(response.players.count, 1)
            XCTAssertEqual(response.state, .waitingForPlayers)
        })
    }

    func testCreateGameMalformedRequest() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())
        let malformedJson = """
        {
          "playWithAI": "yes"
        """
        try app.test(.POST, "/newgame",
                     headers: ["Content-Type": "application/json"],
                     body: ByteBuffer(string: malformedJson)) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testCreateGameEmptyRequest() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())
        try app.test(.POST, "/newgame",
                     headers: ["Content-Type": "application/json"],
                     body: ByteBuffer(string: "{}")) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testCreateGameReturnsExpectedResponse() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "Charlie", playWithAI: true))
        }, afterResponse: { res in
            let response = try res.content.decode(GameWeb.self)
            XCTAssertNotNil(response.id)
            XCTAssertEqual(response.withAI, true)
        })
    }

    func testPlayerTilesAssignedCorrectly() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "Dave", playWithAI: true))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameWeb.self)
            XCTAssertEqual(response.players.count, 2)
            XCTAssertEqual(response.players[0].tile, .x)
            XCTAssertEqual(response.players[1].tile, .o)
        }
    }

    func testUnauthorizedCreateGameFails() throws {
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "Eve", playWithAI: true))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
        })
    }
}


extension AuthorizedUser {
    static func testMiddleware() -> AsyncMiddleware {
        return testMiddleware(playerId: UUID())
    }

    static func testMiddleware(playerId: UUID) -> AsyncMiddleware {
        struct TestMiddleware: AsyncMiddleware {
            let playerId: UUID

            func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
                request.auth.login(AuthorizedUser(id: playerId))
                return try await next.respond(to: request)
            }
        }

        return TestMiddleware(playerId: playerId)
    }
}
