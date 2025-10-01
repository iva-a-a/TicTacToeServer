//
//  GameGetFinishedTests.swift
//  TicTacToe

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Datasource
import Fluent

final class GameGetFinishedTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try? await app.asyncShutdown()
    }

    private func signUpAndSignIn(login: String = UUID().uuidString,
                                 password: String = "password") throws -> String {
        try app.test(.POST, "signup", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        })

        var accessToken: String?
        try app.test(.POST, "signin", beforeRequest: { req in
            try req.content.encode(JwtRequest(login: login, password: password))
        }, afterResponse: { res in
            let response = try res.content.decode(JwtResponse.self)
            accessToken = response.accessToken
        })

        return try XCTUnwrap(accessToken)
    }

    private func insertFinishedGame(for userId: UUID, winnerId: UUID? = nil, isDraw: Bool = false) throws -> UUID {
        let grid = Grid(cells: Array(repeating: Array(repeating: 0, count: 3), count: 3))
        let game = GameData(grid: grid,
                            state: .finished,
                            playerXId: userId,
                            playerOId: nil,
                            currentTurnPlayerId: nil,
                            winnerId: winnerId,
                            isDraw: isDraw,
                            withAI: true,
                            dateСreation: Date())
        try game.save(on: app.db).wait()
        return try XCTUnwrap(game.id)
    }
    
    private func insertWaitingGame(for userId: UUID) throws -> UUID {
        let grid = Grid(cells: Array(repeating: Array(repeating: 0, count: 3), count: 3))
        let game = GameData(grid: grid,
                            state: .waiting,
                            playerXId: userId,
                            playerOId: nil,
                            currentTurnPlayerId: nil,
                            winnerId: nil,
                            isDraw: false,
                            withAI: true,
                            dateСreation: Date())
        try game.save(on: app.db).wait()
        return try XCTUnwrap(game.id)
    }
    
    private func insertProgressGame(for userId: UUID) throws -> UUID {
        let grid = Grid(cells: Array(repeating: Array(repeating: 0, count: 3), count: 3))
        let game = GameData(grid: grid,
                            state: .inProgress,
                            playerXId: userId,
                            playerOId: nil,
                            currentTurnPlayerId: nil,
                            winnerId: nil,
                            isDraw: false,
                            withAI: true,
                            dateСreation: Date())
        try game.save(on: app.db).wait()
        return try XCTUnwrap(game.id)
    }

    func testGetFinishedGamesEmptyList() throws {
        let token = try signUpAndSignIn()
        try app.test(.GET, "/games/finished", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: token)
        }, afterResponse: { res in
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 0)
        })
    }

    func testGetFinishedGamesUnauthorized() throws {
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testGetFinishedGamesUnauthorizedButFinished() throws {
        let playerId = UUID()
        _ = try insertFinishedGame(for: playerId, winnerId: playerId)
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testGetFinishedGamesWithOneFinishedGame() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let gameId = try insertFinishedGame(for: playerId, winnerId: playerId)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games[0].id, gameId)
            XCTAssertEqual(response.games[0].state, .winner(playerId))
        }
    }
    
    func testGetFinishedGamesWithTwoFinishedGame() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let gameId1 = try insertFinishedGame(for: playerId, winnerId: playerId)
        let gameId2 = try insertFinishedGame(for: playerId, winnerId: playerId)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games[0].id, gameId1)
            XCTAssertEqual(response.games[0].state, .winner(playerId))
            XCTAssertEqual(response.games[1].id, gameId2)
            XCTAssertEqual(response.games[1].state, .winner(playerId))
        }
    }
    
    func testGetFinishedGamesWithFinishedAndWaitingGames() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let finishedGameId = try insertFinishedGame(for: playerId, winnerId: playerId)
        _ = try insertWaitingGame(for: playerId) // Не должна вернуться
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 1)
            XCTAssertEqual(response.games[0].id, finishedGameId)
            XCTAssertEqual(response.games[0].state, .winner(playerId))
        }
    }
    
    func testGetFinishedGamesWithOnlyInProgressGame() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        _ = try insertProgressGame(for: playerId)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertTrue(response.games.isEmpty)
        }
    }
    
    func testGetFinishedGamesWithFinishedAndInProgressGames() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let finishedGameId = try insertFinishedGame(for: playerId, winnerId: playerId)
        _ = try insertProgressGame(for: playerId)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 1)
            XCTAssertEqual(response.games[0].id, finishedGameId)
            XCTAssertEqual(response.games[0].state, .winner(playerId))
        }
    }
    
    func testGetFinishedGamesWithWinAndDrawGames() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let winGameId = try insertFinishedGame(for: playerId, winnerId: playerId)
        let drawGameId = try insertFinishedGame(for: playerId, isDraw: true)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 2)
            
            let winGame = response.games.first { $0.id == winGameId }
            XCTAssertEqual(winGame?.state, .winner(playerId))
            
            let drawGame = response.games.first { $0.id == drawGameId }
            XCTAssertEqual(drawGame?.state, .draw)
        }
    }
    
    func testGetFinishedGamesWithMixedStates() throws {
        let playerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let finishedGameId1 = try insertFinishedGame(for: playerId, winnerId: playerId)
        let finishedGameId2 = try insertFinishedGame(for: playerId, isDraw: true)
        _ = try insertWaitingGame(for: playerId)
        _ = try insertProgressGame(for: playerId)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 2)
            
            let gameIds = response.games.map { $0.id }
            XCTAssertTrue(gameIds.contains(finishedGameId1))
            XCTAssertTrue(gameIds.contains(finishedGameId2))
        }
    }
    
    func testGetFinishedGamesWithDifferentWinners() throws {
        let playerId = UUID()
        let opponentId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))
        
        let winGameId = try insertFinishedGame(for: playerId, winnerId: playerId)
        let loseGameId = try insertFinishedGame(for: playerId, winnerId: opponentId)
        let drawGameId = try insertFinishedGame(for: playerId, isDraw: true)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 3)
            
            let winGame = response.games.first { $0.id == winGameId }
            XCTAssertEqual(winGame?.state, .winner(playerId))
            
            let loseGame = response.games.first { $0.id == loseGameId }
            XCTAssertEqual(loseGame?.state, .winner(opponentId))
            
            let drawGame = response.games.first { $0.id == drawGameId }
            XCTAssertEqual(drawGame?.state, .draw)
        }
    }
    
    func testGetFinishedGamesWithOtherPlayersGames() throws {
        let playerId = UUID()
        let otherPlayerId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerId))

        let myGameId = try insertFinishedGame(for: playerId, winnerId: playerId)

        _ = try insertFinishedGame(for: otherPlayerId, winnerId: otherPlayerId)
        
        try app.test(.GET, "/games/finished") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(GamesResponse.self)
            XCTAssertEqual(response.games.count, 1)
            XCTAssertEqual(response.games[0].id, myGameId)
        }
    }
}
