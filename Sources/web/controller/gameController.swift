//
//  web/controller/gameController.swift
//  TicTacToe

import Vapor
import domain
import datasource

public struct GameResponse: Content {
    let game: GameWeb
    var message: String?
}

public final class GameController: Sendable {
    private let gameRepository: any GameRepository
    private let gameService: any GameService
    
    public init(gameRepository: any GameRepository, gameService: any GameService) {
        self.gameRepository = gameRepository
        self.gameService = gameService
    }
    
    public func makeMove(req: Request) async throws -> GameResponse {
        let gameId = try validateGameId(from: req)
        let incomingGame = try req.content.decode(GameWeb.self)
        try validateIncomingGame(incomingGame, gameId)

        var domainGame = MapperWebDomain.toDomain(incomingGame)
        let existingGame = gameRepository.getGame(by: gameId)
        try validateExistingGame(existingGame: existingGame, gameId: gameId)

        try validateMove(for: existingGame!, domainGame: domainGame)

        if gameService.isGameOver(domainGame) {
            let response = GameResponse(
                game: await MapperWebDomain.toWeb(domainGame),
                message: "Game over: Player wins!"
            )
            gameRepository.deleteGame(by: gameId)
            return response
        }
        
        await gameRepository.saveGame(domainGame)
        domainGame = gameService.getNextMove(for: domainGame)
        await gameRepository.saveGame(domainGame)
        if gameService.isGameOver(domainGame) {
            let response = GameResponse(
                game: await MapperWebDomain.toWeb(domainGame),
                message: "Game over: AI wins!"
            )
            gameRepository.deleteGame(by: gameId)
            return response
        }
        return GameResponse(
            game: await MapperWebDomain.toWeb(domainGame),
            message: nil
        )
    }

    private func validateGameId(from req: Request) throws -> UUID {
        guard let gameId = req.parameters.get("gameId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid game ID")
        }
        return gameId
    }

    private func validateIncomingGame(_ incomingGame: GameWeb, _ gameId: UUID) throws {
        guard incomingGame.id == gameId else {
            throw Abort(.badRequest, reason: "Game ID in path and body mismatch")
        }
    }

    func validateExistingGame(existingGame: GameDomain?, gameId: UUID) throws {
        guard existingGame != nil else {
            throw Abort(.notFound, reason: "Game not found")
        }
    }

    private func validateMove(for existingGame: GameDomain, domainGame: GameDomain) throws {
        if !gameService.validateMove(for: existingGame, for: domainGame) {
            throw Abort(.badRequest, reason: "Invalid move")
        }
    }
}
