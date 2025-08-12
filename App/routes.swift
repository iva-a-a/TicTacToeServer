//
//  routes.swift
//  TicTacToe

import Vapor
import Web
import Di
import Domain
import Datasource

@MainActor func routes(_ app: Application) throws {
    ContainerProvider.shared.setupDependencies(app: app)
    let dependencies = try Dependencies(app: app)

    let authenticator = UserAuthenticator(userService: dependencies.userService)
    app.grouped(authenticator).post("signup", use: dependencies.userController.signUp)
    app.grouped(authenticator).post("signin", use: dependencies.userController.signIn)

    let protected = app.grouped(authenticator)
        .grouped(AuthorizedUser.guardMiddleware())

    // endpoints
    // создание игры
    protected.post("newgame", use: dependencies.gameController.createGame)
    // получение доступных для присоединения игр
    protected.get("games", "available", use: dependencies.gameController.getAvailableGames)
    // присоединение к игре
    protected.post("game", ":gameId", "join", use: dependencies.gameController.joinGame)
    // получение текущей игры
    protected.get("game", ":gameId", use: dependencies.gameController.getGame)
    // сделать ход
    protected.post("game", ":gameId", "move", use: dependencies.gameController.makeMove)
    // получение информации о пользователе
    protected.get("user", ":userId", use: dependencies.userController.getUserById)
}

@MainActor private struct Dependencies {
    let gameController: GameController
    let repository: any GameRepository
    let userController: UserController
    let userService: any UserService

    init(app: Application) throws {
        let container = ContainerProvider.shared.container

        guard let gameController = container.resolve(GameController.self),
              let repository = container.resolve((any GameRepository).self),
              let userController = container.resolve(UserController.self),
              let userService = container.resolve((any UserService).self)
        else {
            throw Abort(.internalServerError, reason: "Dependency injection failed")
        }

        self.userController = userController
        self.userService = userService
        self.gameController = gameController
        self.repository = repository
    }
}
