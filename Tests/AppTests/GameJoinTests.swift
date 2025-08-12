//
//  GameJoinTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class GameJoinGameTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try await GameData.query(on: app.db).delete()
        try? await app.asyncShutdown()
    }

    func testSuccessfulJoinGame() throws {
        let player2 = UUID()

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))

        var createdGameId: UUID?

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            createdGameId = response.game.id
        })

        guard let gameId = createdGameId else {
            XCTFail("Game not created")
            return
        }

        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            XCTAssertEqual(response.game.players.count, 2)
            XCTAssertEqual(response.game.state, .playerTurn(player2))
        })
    }

    func testJoinNonexistentGameReturnsNotFound() throws {
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))

        let fakeGameId = UUID()

        try app.test(.POST, "/game/\(fakeGameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: UUID()))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.gameNotFound.status)
            XCTAssertTrue(res.body.string.contains(GameError.gameNotFound.reason))
        })
    }

    func testJoinGameWithTwoPlayersFails() throws {
        let player1 = UUID()
        let player2 = UUID()
        let player3 = UUID()

        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
        })

        guard let gameId = gameId else {
            XCTFail("Game not created")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player3))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player3))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidCountPlayers.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidCountPlayers.reason))
        })
    }

    func testJoinGameWithInvalidUUIDPath() throws {
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))

        try app.test(.POST, "/game/invalid-uuid/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: UUID()))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidGameId.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidGameId.reason))
        })
    }

    func testUnauthorizedJoinGameFails() throws {
        let gameId = UUID()

        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: UUID()))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidAuthorizedUser.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidAuthorizedUser.reason))
        })
    }
}
