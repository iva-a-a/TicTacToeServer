//
//  GameGetTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class GameGetTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try? await app.asyncShutdown()
    }

    func testGetExistingGame() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())

        var createdGameId: UUID?

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "me", playWithAI: true))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameWeb.self)
            createdGameId = response.id
        })

        guard let gameId = createdGameId else {
            XCTFail("Game ID not returned from creation")
            return
        }

        try app.test(.GET, "/game/\(gameId)") { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            XCTAssertEqual(game.id, gameId)
            XCTAssertEqual(game.players.count, 2)
            XCTAssertEqual(game.players[0].tile, .x)
            XCTAssertEqual(game.players[1].tile, .o)
        }
    }

    func testGetGameWithInvalidId() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())

        try app.test(.GET, "/game/invalid-uuid") { res in
            XCTAssertEqual(res.status, RequestError.invalidGameId.status)
            XCTAssertTrue(res.body.string.contains(RequestError.invalidGameId.reason))
        }
    }

    func testGetNonexistentGame() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())
        let nonExistentGameId = UUID()

        try app.test(.GET, "/game/\(nonExistentGameId)") { res in
            XCTAssertEqual(res.status, GameError.gameNotFound.status)
            XCTAssertTrue(res.body.string.contains(GameError.gameNotFound.reason))
        }
    }

    func testUnauthorizedGameAccess() throws {
        let randomGameId = UUID()

        try app.test(.GET, "/game/\(randomGameId)") { res in
            XCTAssertEqual(res.status, RequestError.invalidAuthorizedUser.status)
            XCTAssertTrue(res.body.string.contains(RequestError.invalidAuthorizedUser.reason))
        }
    }
}
