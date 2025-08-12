//
//  GameGetAvailableGamesTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class GameGetAvailableGamesTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try await GameData.query(on: app.db).delete()
        try? await app.asyncShutdown()
    }

    func testGetAvailableGamesWhenAvailable() throws {
        let test = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: test))

        let playerId = UUID()

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .ok)
            let games = try res.content.decode([GameWeb].self)
            XCTAssertFalse(games.isEmpty)
            for game in games {
                XCTAssertEqual(game.players.count, 1)
                XCTAssertEqual(game.state, .waitingForPlayers)
            }
        }
    }

    func testGetAvailableGamesWhenNoneExist() throws {
        app.middleware.use(AuthorizedUser.testMiddleware())

        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .ok)
            let games = try res.content.decode([GameWeb].self)
            XCTAssertTrue(games.isEmpty)
        }
    }

    func testUnauthorizedAccessToAvailableGames() throws {
        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("User not authenticated"))
        }
    }

    func testAvailableGamesDoNotIncludeGamesOfCurrentUser() throws {
        let currentUserId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: currentUserId))

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }

        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .ok)
            let games = try res.content.decode([GameWeb].self)
            XCTAssertTrue(games.isEmpty, "Current user's own game should not be listed as available")
        }
    }
    
    func testGameWithTwoPlayersIsNotAvailable() throws {
        let user1 = UUID()
        let user2 = UUID()
        
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: user1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            let gameId = response.game.id

            try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
                try req.content.encode(JoinGameRequest(playerId: user2))
            }) { res in
                XCTAssertEqual(res.status, .ok)
            }
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))

        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .ok)
            let games = try res.content.decode([GameWeb].self)
            XCTAssertTrue(games.isEmpty, "Game with 2 players should not be listed as available")
        }
    }
    
    func testGameNotInWaitingStateIsNotAvailable() throws {
        let user1 = UUID()
        let user2 = UUID()

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: user1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: true))
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: user2))

        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .ok)
            let games = try res.content.decode([GameWeb].self)
            XCTAssertTrue(games.isEmpty, "Game not in waitingForPlayers state should not be listed")
        }
    }

    func testMultipleAvailableGamesFromOtherUsers() throws {
        let user1 = UUID()
        let user2 = UUID()
        let currentUser = UUID()

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: user1))
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: user2))
        for _ in [user1, user2] {
            try app.test(.POST, "/newgame", beforeRequest: { req in
                try req.content.encode(CreateGameRequest(playWithAI: false))
            }) { res in
                XCTAssertEqual(res.status, .ok)
            }
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: currentUser))

        try app.test(.GET, "/games/available") { res in
            XCTAssertEqual(res.status, .ok)
            let games = try res.content.decode([GameWeb].self)
            XCTAssertEqual(games.count, 2, "Should return all available games not created by current user")
        }
    }

}
