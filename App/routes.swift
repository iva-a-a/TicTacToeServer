//
//  routes.swift
//  TicTacToe

import Vapor
import JWTKit
import Web
import Di
import Domain
import Datasource

@MainActor func routes(_ app: Application) throws {
    ContainerProvider.shared.setupDependencies(app: app)
    let dependencies = try Dependencies(app: app)

    // авторизация и регистрация
    app.post("signup", use: dependencies.userController.signUp)
    app.post("signin", use: dependencies.userController.signIn)
    // обновление токенов
    app.post("token", "refresh-access", use: dependencies.userController.refreshAccessToken)
    app.post("token", "refresh-refresh", use: dependencies.userController.refreshRefreshToken)

    let protected = app
        .grouped(JwtAuthenticator(jwtProvider: dependencies.jwtProvider))
        .grouped(AuthorizedUser.guardMiddleware())

    // защищенные endpoints
    // создание игры
    protected.post("newgame", use: dependencies.gameController.createGame)
    // получение доступных для присоединения игр
    protected.get("games", "available", use: dependencies.gameController.getAvailableGames)
    // получение незавершенных игр
    protected.get("games", "inprogress", use: dependencies.gameController.getInProgressGames)
    // присоединение к игре
    protected.post("game", ":gameId", "join", use: dependencies.gameController.joinGame)
    // получение текущей игры
    protected.get("game", ":gameId", use: dependencies.gameController.getGame)
    // сделать ход
    protected.post("game", ":gameId", "move", use: dependencies.gameController.makeMove)
    // получение информации о пользователе
    protected.get("user", ":userId", use: dependencies.userController.getUserById)
    // получение информации о себе через accessToken
    protected.get("user", "me", use: dependencies.userController.getMe)
    // получение завершенных игр по токену
    protected.get("games", "finished", use: dependencies.gameController.getFinishedGames)
    // получения первых N лучших игроков
    protected.get("top-players", use: dependencies.gameController.getTopPlayers)

}

@MainActor private struct Dependencies {
    let gameController: GameController
    let gameStatsService: any GameStatsService
    let userController: UserController
    let userService: any UserService
    let jwtProvider: any JwtProvider

    init(app: Application) throws {
        let container = ContainerProvider.shared.container

        guard let gameController = container.resolve(GameController.self),
              let gameStatsService = container.resolve((any GameStatsService).self),
              let userController = container.resolve(UserController.self),
              let userService = container.resolve((any UserService).self),
              let jwtProvider = container.resolve((any JwtProvider).self)
        else {
            throw Abort(.internalServerError, reason: "Dependency injection failed")
        }
        
        self.gameController = gameController
        self.gameStatsService = gameStatsService
        self.userController = userController
        self.userService = userService
        self.jwtProvider = jwtProvider

    }
}
