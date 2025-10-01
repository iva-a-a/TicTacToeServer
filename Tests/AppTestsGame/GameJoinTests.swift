//
//  GameJoinTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class GameJoinTests: XCTestCase {
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
        let player1Id = UUID()
        let player2Id = UUID()

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1Id))

        var createdGameId: UUID?

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameWeb.self)
            createdGameId = response.id
        })

        guard let gameId = createdGameId else {
            XCTFail("Game not created")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2Id))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2Id, playerLogin: "player2"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameWeb.self)
            XCTAssertEqual(response.players.count, 2)
            XCTAssertEqual(response.state, .playerTurn(player1Id))
        })
    }

    func testJoinNonexistentGameReturnsNotFound() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))

        let fakeGameId = UUID()

        try app.test(.POST, "/game/\(fakeGameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: UUID(), playerLogin: "playerX"))
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
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            let response = try res.content.decode(GameWeb.self)
            gameId = response.id
        })

        guard let gameId = gameId else {
            XCTFail("Game not created")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2, playerLogin: "player2"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player3))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player3, playerLogin: "player3"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidCountPlayers.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidCountPlayers.reason))
        })
    }

    func testJoinGameWithInvalidUUIDPath() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))

        try app.test(.POST, "/game/invalid-uuid/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: playerId, playerLogin: "playerX"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, RequestError.invalidGameId.status)
            XCTAssertTrue(res.body.string.contains(RequestError.invalidGameId.reason))
        })
    }

    func testUnauthorizedJoinGameFails() throws {
        let gameId = UUID()

        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: UUID(), playerLogin: "playerX"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, RequestError.invalidAuthorizedUser.status)
            XCTAssertTrue(res.body.string.contains(RequestError.invalidAuthorizedUser.reason))
        })
    }
}
