//
// routes.swift
//  TicTacToe

import Vapor
import web
import di
import domain
import datasource

@MainActor func routes(_ app: Application) throws {

    let dependencies = try Dependencies(app: app)
    
    app.post("game", ":gameId", use: dependencies.gameController.makeMove)
    
    app.post("newgame") { req async throws -> GameWeb in
        let newGame = GameDomain(board: BoardDomain(), id: UUID())
        await dependencies.repository.saveGame(newGame)
        return await MapperWebDomain.toWeb(newGame)
    }
}

@MainActor private struct Dependencies {
    let gameController: GameController
    let repository: any GameRepository
    
    init(app: Application) throws {
        let container = ContainerProvider.shared.container
        
        guard let gameController = container.resolve(GameController.self),
              let repository = container.resolve((any GameRepository).self) else {
            throw Abort(.internalServerError, reason: "Dependency injection failed")
        }
        
        self.gameController = gameController
        self.repository = repository
    }
}
