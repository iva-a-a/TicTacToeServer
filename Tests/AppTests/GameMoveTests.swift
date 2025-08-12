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
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
        })

        guard let gameId = gameId else {
            XCTFail("Game ID not returned")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))

        let gameState = GameWeb(
            board: BoardWeb(grid: [
                [.empty, .empty, .empty],
                [.empty, .x, .empty],
                [.empty, .empty, .empty]
            ]),
            id: gameId,
            state: .playerTurn(player2),
            players: [
                PlayerWeb(id: player1, tile: .x),
                PlayerWeb(id: player2, tile: .o)
            ]
        )

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(gameState)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            XCTAssertNil(response.message)
            XCTAssertEqual(response.game.board.grid[1][1], .x)
        })
    }

    func testMoveWithInvalidUUIDInPath() throws {
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))
        let invalidId = "invalid-uuid"

        try app.test(.POST, "/game/\(invalidId)/move", beforeRequest: { req in
            try req.content.encode(GameWeb.mock(id: UUID()))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidGameId.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidGameId.reason))
        })
    }

    func testMoveWithMismatchedGameIdInBody() throws {
        let pathId = UUID()
        let bodyId = UUID()

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))

        try app.test(.POST, "/game/\(pathId)/move", beforeRequest: { req in
            try req.content.encode(GameWeb.mock(id: bodyId))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.gameIdMismatch.status)
            XCTAssertTrue(res.body.string.contains(GameError.gameIdMismatch.reason))
        })
    }

    func testMoveWithNonExistentGame() throws {
        let id = UUID()

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: UUID()))

        try app.test(.POST, "/game/\(id)/move", beforeRequest: { req in
            try req.content.encode(GameWeb.mock(id: id))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.gameNotFound.status)
            XCTAssertTrue(res.body.string.contains(GameError.gameNotFound.reason))
        })
    }

    func testUnauthorizedMoveFails() throws {
        let id = UUID()

        try app.test(.POST, "/game/\(id)/move", beforeRequest: { req in
            try req.content.encode(GameWeb.mock(id: id))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, GameError.invalidAuthorizedUser.status)
            XCTAssertTrue(res.body.string.contains(GameError.invalidAuthorizedUser.reason))
        })
    }
    
    func testInvalidMoveFails() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))

        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
        })

        guard let gameId = gameId else {
            XCTFail("Game ID not returned")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))

        let board = BoardWeb(grid: [
            [.o, .empty, .empty],
            [.empty, .empty, .empty],
            [.empty, .empty, .empty]
        ])

        let invalidMove = GameWeb(
            board: board,
            id: gameId,
            state: .playerTurn(player2),
            players: [
                PlayerWeb(id: player1, tile: .x),
                PlayerWeb(id: player2, tile: .o)
            ]
        )

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(invalidMove)
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
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
        })

        guard let gameId = gameId else {
            XCTFail("Game ID not returned")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        })

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))

        let board = BoardWeb(grid: [
            [.empty, .o, .empty],
            [.empty, .empty, .empty],
            [.empty, .empty, .empty]
        ])

        let wrongPlayerMove = GameWeb(
            board: board,
            id: gameId,
            state: .playerTurn(player1),
            players: [
                PlayerWeb(id: player1, tile: .x),
                PlayerWeb(id: player2, tile: .o)
            ]
        )

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(wrongPlayerMove)
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
            try req.content.encode(CreateGameRequest(playWithAI: true))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
            XCTAssertTrue(response.game.withAI)
            XCTAssertEqual(response.game.players.count, 2)
        })

        guard let gameId = gameId else {
            XCTFail("Game ID not returned")
            return
        }

        var currentGame: GameWeb?
        try app.test(.GET, "/game/\(gameId)", afterResponse: { res in
            currentGame = try res.content.decode(GameWeb.self)
        })

        guard var gameState = currentGame else {
            XCTFail("Failed to get initial game state")
            return
        }

        gameState.board.grid[1][1] = .x
        gameState.state = .playerTurn(playerId)

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(gameState)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)

            let aiMoves = response.game.board.grid.flatMap { $0 }.filter { $0 == .o }
            XCTAssertEqual(aiMoves.count, 1, "AI should make exactly one move after player")

            if case .playerTurn(let currentPlayerId) = response.game.state {
                XCTAssertEqual(currentPlayerId, playerId)
            } else {
                XCTFail("Game should be in playerTurn state after AI move")
            }
        })
    }
    
    func testPlayerWinsGame() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
        })

        guard let gameId = gameId else {
            XCTFail("Game ID not returned")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        })

        var currentGame: GameWeb?
        try app.test(.GET, "/game/\(gameId)", afterResponse: { res in
            currentGame = try res.content.decode(GameWeb.self)
        })

        guard var gameState = currentGame else {
            XCTFail("Failed to get game state")
            return
        }

        let moves: [(grid: [[TileWeb]], currentPlayer: UUID)] = [
            (
                [
                    [.x, .empty, .empty],
                    [.empty, .empty, .empty],
                    [.empty, .empty, .empty]
                ],
                player1
            ),
            (
                [
                    [.x, .empty, .empty],
                    [.o, .empty, .empty],
                    [.empty, .empty, .empty]
                ],
                player2
            ),
            (
                [
                    [.x, .x, .empty],
                    [.o, .empty, .empty],
                    [.empty, .empty, .empty]
                ],
                player1
            ),
            (
                [
                    [.x, .x, .empty],
                    [.o, .o, .empty],
                    [.empty, .empty, .empty]
                ],
                player2
            ),
            (
                [
                    [.x, .x, .x],
                    [.o, .o, .empty],
                    [.empty, .empty, .empty]
                ],
                player1
            )
        ]

        for move in moves.dropLast() {
            gameState.board.grid = move.grid
            gameState.state = .playerTurn(move.currentPlayer)
            try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
                try req.content.encode(gameState)
            })
        }

        let lastMove = moves.last!
        gameState.board.grid = lastMove.grid
        gameState.state = .playerTurn(lastMove.currentPlayer)

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(gameState)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)

            if case .winner(let winnerId) = response.game.state {
                XCTAssertEqual(winnerId, player1)
                XCTAssertEqual(response.message, "Game over: \(winnerId) wins!")
            } else {
                XCTFail("Expected winner state, got \(response.game.state)")
            }
        })
    }
    
    func testGameEndsInDraw() throws {
        let player1 = UUID()
        let player2 = UUID()
        var gameId: UUID?

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))
        try app.test(.POST, "/newgame", beforeRequest: { req in
            try req.content.encode(CreateGameRequest(playWithAI: false))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)
            gameId = response.game.id
        })

        guard let gameId = gameId else {
            XCTFail("Game ID not returned")
            return
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player2))
        try app.test(.POST, "/game/\(gameId)/join", beforeRequest: { req in
            try req.content.encode(JoinGameRequest(playerId: player2))
        })

        var currentGame: GameWeb?
        try app.test(.GET, "/game/\(gameId)", afterResponse: { res in
            currentGame = try res.content.decode(GameWeb.self)
        })

        guard var gameState = currentGame else {
            XCTFail("Failed to get game state")
            return
        }
        let moves: [(grid: [[TileWeb]], currentPlayer: UUID)] = [
            (
                [
                    [.x, .empty, .empty],
                    [.empty, .empty, .empty],
                    [.empty, .empty, .empty]
                ],
                player1
            ),
            (
                [
                    [.x, .o, .empty],
                    [.empty, .empty, .empty],
                    [.empty, .empty, .empty]
                ],
                player2
            ),
            (
                [
                    [.x, .o, .x],
                    [.empty, .empty, .empty],
                    [.empty, .empty, .empty]
                ],
                player1
            ),
            (
                [
                    [.x, .o, .x],
                    [.empty, .o, .empty],
                    [.empty, .empty, .empty]
                ],
                player2
            ),
            (
                [
                    [.x, .o, .x],
                    [.x, .o, .empty],
                    [.empty, .empty, .empty]
                ],
                player1
            ),
            (
                [
                    [.x, .o, .x],
                    [.x, .o, .o],
                    [.empty, .empty, .empty]
                ],
                player2
            ),
            (
                [
                    [.x, .o, .x],
                    [.x, .o, .o],
                    [.empty, .x, .empty]
                ],
                player1
            ),
            (
                [
                    [.x, .o, .x],
                    [.x, .o, .o],
                    [.o, .x, .empty]
                ],
                player2
            ),
            (
                [
                    [.x, .o, .x],
                    [.x, .o, .o],
                    [.o, .x, .x]
                ],
                player1
            )
        ]

        for move in moves.dropLast() {
            gameState.board.grid = move.grid
            gameState.state = .playerTurn(move.currentPlayer)
            try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
                try req.content.encode(gameState)
            })
        }

        let lastMove = moves.last!
        gameState.board.grid = lastMove.grid
        gameState.state = .playerTurn(lastMove.currentPlayer)

        try app.test(.POST, "/game/\(gameId)/move", beforeRequest: { req in
            try req.content.encode(gameState)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GameResponse.self)

            if case .draw = response.game.state {
            } else {
                XCTFail("Expected draw state, got \(response.game.state)")
            }

            XCTAssertEqual(response.message, "Game over: Draw!")
        })
    }
}

extension GameWeb {
    static func mock(id: UUID) -> GameWeb {
        return GameWeb(
            board: BoardWeb(grid: [
                [.empty, .empty, .empty],
                [.empty, .empty, .empty],
                [.empty, .empty, .empty]
            ]),
            id: id,
            state: .waitingForPlayers,
            players: [],
            withAI: false
        )
    }
}
