//
//  GameGetTopPlayersTests.swift
//  TicTacToe
//

import XCTest
import XCTVapor
@testable import App
import Domain
import Datasource
import Fluent
import Web

final class GameGetTopPlayersTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try? await app.asyncShutdown()
    }

    private func createUser() throws -> UUID {
        let id = UUID()
        let login = UUID().uuidString
        let user = UserData(id: id, login: login, password: "password")
        try user.create(on: app.db).wait()
        return id
    }

    private func insertFinishedGame(playerX: UUID, playerO: UUID?, winner: UUID? = nil, draw: Bool = false, withAI: Bool = false) throws -> UUID {
        let grid = Grid(cells: Array(repeating: Array(repeating: 0, count: 3), count: 3))
        let game = GameData(
            grid: grid,
            state: .finished,
            playerXId: playerX,
            playerOId: playerO,
            currentTurnPlayerId: nil,
            winnerId: draw ? nil : winner,
            isDraw: draw,
            withAI: withAI,
            dateСreation: Date()
        )
        try game.save(on: app.db).wait()
        return try XCTUnwrap(game.id)
    }

    func testGetTopPlayersEmpty() throws {
        let userId = UUID()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: userId))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            XCTAssertTrue(response.playersStats.isEmpty)
        }
    }

    func testGetTopPlayersSingleGameWin() throws {
        let player1 = try createUser()
        let player2 = try createUser()
        _ = try insertFinishedGame(playerX: player1, playerO: player2, winner: player1)

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 2)

            let ratios = Dictionary(uniqueKeysWithValues: players.map { ($0.userId, $0.winRatio) })
            XCTAssertEqual(ratios[player1], 1.0)
            XCTAssertEqual(ratios[player2], 0.0)
        }
    }

    func testGetTopPlayersWithDraw() throws {
        let player1 = try createUser()
        let player2 = try createUser()
        _ = try insertFinishedGame(playerX: player1, playerO: player2, draw: true)

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 2)

            let ratios = Dictionary(uniqueKeysWithValues: players.map { ($0.userId, $0.winRatio) })
            XCTAssertEqual(ratios[player1], 0.0)
            XCTAssertEqual(ratios[player2], 0.0)
        }
    }

    func testGetTopPlayersWithNilWinner() throws {
        let player = try createUser()
        _ = try insertFinishedGame(playerX: player, playerO: nil, winner: nil, withAI: true)

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 1)

            let ratio = players.first!.winRatio
            XCTAssertEqual(ratio, 0.0)
        }
    }

    func testGetTopPlayersMultipleGames() throws {
        let player1 = try createUser()
        let player2 = try createUser()
        let player3 = try createUser()

        _ = try insertFinishedGame(playerX: player1, playerO: player2, winner: player1)
        _ = try insertFinishedGame(playerX: player1, playerO: player3, winner: player3)
        _ = try insertFinishedGame(playerX: player2, playerO: player3, winner: player2)

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player1))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 3)

            let ratios = Dictionary(uniqueKeysWithValues: players.map { ($0.userId, $0.winRatio) })
            XCTAssertEqual(ratios[player1], 0.5)
            XCTAssertEqual(ratios[player2], 0.5)
            XCTAssertEqual(ratios[player3], 0.5)
        }
    }

    func testGetTopPlayersWithLimit() throws {
        var playerIds: [UUID] = []
        for _ in 0..<5 {
            playerIds.append(try createUser())
        }

        for i in 0..<playerIds.count-1 {
            _ = try insertFinishedGame(playerX: playerIds[i], playerO: playerIds[i+1], winner: playerIds[i])
        }

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerIds[0]))

        try app.test(.GET, "/top-players?limit=3") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 3)
        }
    }

    func testGetTopPlayersUserWithoutGames() throws {
        let player = try createUser()
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: player))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 0)
        }
    }
    
    func testGetTopPlayersComplexScenario() throws {
        let players: [UUID] = (0..<6).map { _ in try! createUser() }

        _ = try insertFinishedGame(playerX: players[0], playerO: players[1], winner: players[0])
        _ = try insertFinishedGame(playerX: players[1], playerO: players[2], winner: players[1])
        _ = try insertFinishedGame(playerX: players[2], playerO: players[3], draw: true)
        _ = try insertFinishedGame(playerX: players[5], playerO: players[0], winner: players[0])

        app.middleware.use(AuthorizedUser.testMiddleware(playerId: players[0]))

        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let result = response.playersStats
            XCTAssertEqual(result.count, 5)

            let ratios = Dictionary(uniqueKeysWithValues: result.map { ($0.userId, $0.winRatio) })

            XCTAssertEqual(ratios[players[0]], 1.0)
            XCTAssertEqual(ratios[players[1]], 0.5)
            XCTAssertEqual(ratios[players[2]], 0.0)
            XCTAssertEqual(ratios[players[3]], 0.0)
            XCTAssertEqual(ratios[players[5]], 0.0)

            let sortedIds = result.map { $0.userId }
            XCTAssertEqual(sortedIds[0], players[0])
            XCTAssertEqual(sortedIds[1], players[1])
        }
    }

    func testAIPlayerNotIncludedInTop() throws {
        let human = try createUser()
        _ = try insertFinishedGame(playerX: human, playerO: nil, winner: human, withAI: true)
        
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: human))
        
        try app.test(.GET, "/top-players") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 1)
            XCTAssertEqual(players.first!.userId, human)
            XCTAssertEqual(players.first!.winRatio, 1.0)
        }
    }

    func testAIWinnerNotExcludedFromStats() throws {
        let playerX = try createUser()
        let playerO = try createUser()

        _ = try insertFinishedGame(playerX: playerX, playerO: playerO, winner: playerO, withAI: true)
        
        app.middleware.use(AuthorizedUser.testMiddleware(playerId: playerX))
        
        try app.test(.GET, "/top-players") { res in
            let response = try res.content.decode(PlayersStatsWeb.self)
            let players = response.playersStats
            XCTAssertEqual(players.count, 1)
            let ratios = Dictionary(uniqueKeysWithValues: players.map { ($0.userId, $0.winRatio) })
            XCTAssertEqual(ratios[playerX], 0.0)
        }
    }
}
