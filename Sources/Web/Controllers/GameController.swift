//
//  GameController.swift
//  TicTacToe

import Vapor
import Domain
import Datasource

public final class GameController: Sendable {
    private let gameService: any GameService
    private let gameStatsService: any GameStatsService
    
    public init(gameService: any GameService, gameStatsService: any GameStatsService) {
        self.gameService = gameService
        self.gameStatsService = gameStatsService
    }

    public func createGame(req: Request) async throws -> GameWeb {
        guard let userId = req.auth.get(AuthorizedUser.self)?.id else {
            throw RequestError.invalidAuthorizedUser
        }

        let request = try req.content.decode(CreateGameRequest.self)
        let game = try await gameService.createGame(by: userId, creator: request.creatorLogin, playWithAI: request.playWithAI)

        return MapperGameWebDomain.toWeb(game)
    }
    
    public func getAvailableGames(req: Request) async throws -> GamesResponse {
        guard let userId = req.auth.get(AuthorizedUser.self)?.id else {
            throw RequestError.invalidAuthorizedUser
        }

        let games = await gameService.getAvailableGames(for: userId)
        return GamesResponse(games: games.map(MapperGameWebDomain.toWeb))
    }
    
    public func getInProgressGames(req: Request) async throws -> GamesResponse {
        guard let userId = req.auth.get(AuthorizedUser.self)?.id else {
            throw RequestError.invalidAuthorizedUser
        }

        let games = await gameService.getInProgressGames(for: userId)
        return GamesResponse(games: games.map(MapperGameWebDomain.toWeb))
    }

    public func getGame(req: Request) async throws -> GameWeb {
        let gameId = try validateGameId(from: req)
        guard let game = await gameService.getGame(by: gameId) else {
            throw RequestError.gameNotFound
        }
        return MapperGameWebDomain.toWeb(game)
    }

    public func getFinishedGames(req: Request) async throws -> GamesResponse {
        guard let userId = req.auth.get(AuthorizedUser.self)?.id else {
            throw RequestError.invalidAuthorizedUser
        }
        let games = await gameService.getFinishedGames(for: userId)
        return GamesResponse(games: games.map(MapperGameWebDomain.toWeb))
    }


    public func joinGame(req: Request) async throws -> GameWeb {
        let gameId = try validateGameId(from: req)
        let request = try req.content.decode(JoinGameRequest.self)
        
        let game = try await gameService.joinGame(gameId: gameId, playerId: request.playerId, playerLogin: request.playerLogin)
        return MapperGameWebDomain.toWeb(game)
    }
    
    public func makeMove(req: Request) async throws -> GameWeb {
        let gameId = try validateGameId(from: req)
        let request = try req.content.decode(MoveRequest.self)

        let game = try await gameService.makeMove(gameId: gameId,
                                                  playerId: request.playerId,
                                                  row: request.row,
                                                  col: request.col)

        return MapperGameWebDomain.toWeb(game)
    }
    
    public func getTopPlayers(req: Request) async throws -> PlayersStatsWeb {
        guard let _ = req.auth.get(AuthorizedUser.self) else {
            throw RequestError.invalidAuthorizedUser
        }

        let limit = (try? req.query.get(Int.self, at: "limit")) ?? 10
        let topPlayers = try await gameStatsService.getTopPlayers(limit: limit)

        return PlayersStatsWeb(playersStats: topPlayers.map(MapperPlayerStatsWebDomain.toWeb))
    }

    private func validateGameId(from req: Request) throws -> UUID {
        guard let gameId = req.parameters.get("gameId", as: UUID.self) else {
            throw RequestError.invalidGameId
        }
        return gameId
    }
}
