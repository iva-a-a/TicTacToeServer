//
//  GameMoveTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource

final class GameMakeMoveTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try await GameData.query(on: app.db).delete()
        try? await app.asyncShutdown()
    }

    func testSuccessfulMove() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            gameId = game.id
        })

        guard let gameId = gameId else { XCTFail("Game not created"); return }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2, playerLogin: "player2"))
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: player1, row: 1, col: 1))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            XCTAssertEqual(game.board.grid[1][1], .x)
        })
    }

    func testMoveWithInvalidUUIDInPath() throws {
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))
        try app.test(.POST, "/game/invalid-uuid/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: UUID(), row: 0, col: 0))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, RequestError.invalidGameId.status)
            XCTAssertTrue(res.body.string.contains(RequestError.invalidGameId.reason))
        })
    }

    func testMoveWithNonExistentGame() throws {
        let id = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))

        try app.test(.POST, "/game/\(id)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: UUID(), row: 0, col: 0))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.gameNotFound.status)
            XCTAssertTrue(res.body.string.contains(GameError.gameNotFound.reason))
        })
    }

    func testUnauthorizedMoveFails() throws {
        let id = UUID()
        try app.test(.POST, "/game/\(id)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: UUID(), row: 0, col: 0))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, RequestError.invalidAuthorizedUser.status)
            XCTAssertTrue(res.body.string.contains(RequestError.invalidAuthorizedUser.reason))
        })
    }

    func testInvalidMoveFails() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            let game = try res.content.decode(GameWeb.self)
            gameId = game.id
        })
        guard let gameId = gameId else { XCTFail("Game not created"); return }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2, playerLogin: "player2"))
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: player2, row: 0, col: 0))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidMove.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidMove.reason))
        })
    }

    func testMoveByWrongPlayerFails() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            let game = try res.content.decode(GameWeb.self)
            gameId = game.id
        })
        guard let gameId = gameId else { XCTFail("Game not created"); return }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2, playerLogin: "player2"))
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: player2, row: 0, col: 0))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidMove.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidMove.reason))
        })
    }

    func testAIMakesMoveAfterPlayer() throws {
        let playerId = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: true))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            gameId = game.id
            XCTAssertTrue(game.withAI)
        })
        guard let gameId = gameId else { XCTFail("Game not created"); return }

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: playerId, row: 1, col: 1))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            let aiMoves = game.board.grid.flatMap { $0 }.filter { $0 == .o }
            XCTAssertEqual(aiMoves.count, 1, "AI should make exactly one move after player")
            if case .playerTurn(let currentPlayer) = game.state {
                XCTAssertEqual(currentPlayer, playerId)
            } else {
                XCTFail("Expected playerTurn after AI move")
            }
        })
    }

    func testPlayerWinsGame() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            let game = try res.content.decode(GameWeb.self)
            gameId = game.id
        })
        guard let gameId = gameId else { XCTFail("Game not created"); return }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2, playerLogin: "player2"))
        })

        let moves: [(player: UUID, row: Int, col: Int)] = [
            (player1, 0, 0),
            (player2, 1, 0),
            (player1, 0, 1),
            (player2, 1, 1),
            (player1, 0, 2)
        ]

        for move in moves.dropLast() {
            app.middleware.use(AuthorizedUser.testMiddleware(playerId: move.player))
            try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
                try req.content.encode(MoveRequest(playerId: move.player, row: move.row, col: move.col))
            })
        }

        let lastMove = moves.last!
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: lastMove.player))
        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: lastMove.player, row: lastMove.row, col: lastMove.col))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            if case .winner(let winner) = game.state {
                XCTAssertEqual(winner, player1)
            } else {
                XCTFail("Expected winner state")
            }
        })
    }

    func testGameEndsInDraw() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(creatorLogin: "player1", playWithAI: false))
        }, afterResponse: { res in
            let game = try res.content.decode(GameWeb.self)
            gameId = game.id
        })
        guard let gameId = gameId else { XCTFail("Game not created"); return }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2, playerLogin: "player2"))
        })

        let moves: [(player: UUID, row: Int, col: Int)] = [
            (player1, 0, 0), (player2, 0, 1), (player1, 0, 2),
            (player2, 1, 1), (player1, 1, 0), (player2, 1, 2),
            (player1, 2, 1), (player2, 2, 0), (player1, 2, 2)
        ]

        for move in moves.dropLast() {
            app.middleware.use(AuthorizedUser.testMiddleware(playerId: move.player))
            try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
                try req.content.encode(MoveRequest(playerId: move.player, row: move.row, col: move.col))
            })
        }

        let lastMove = moves.last!
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: lastMove.player))
        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(MoveRequest(playerId: lastMove.player, row: lastMove.row, col: lastMove.col))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let game = try res.content.decode(GameWeb.self)
            if case .draw = game.state {
            } else {
                XCTFail("Expected draw state")
            }
        })
    }
}
