//
//  ContainerProvider.swift
//  TicTacToe

import Swinject
import Domain
import Datasource
import Web
import Vapor
import JWTKit

public final class ContainerProvider {
    @MainActor public static let shared = ContainerProvider()
    
    public let container: Container
    
    private init() {
        container = Container()
    }
    
    @MainActor public func setupDependencies(app: Application) {
        
        let db = app.db
        
        // JwtProvider
        container.register((any JwtProvider).self) { _ in
            JwtProviderImpl(secret: Environment.get("JWT_SECRET") ?? "secret")
        }
        
        // Repositories
        container.register((any GameRepository).self) { _ in
            GameRepositoryDatabase(db: db)
        }
        container.register((any UserRepository).self) { _ in
            UserRepositoryDatabase(db: db)
        }
        container.register((any GameStatsRepository).self) { _ in
            GameStatsRepositoryDatabase(db: db)
        }
        
        
        // Services
        container.register((any GameService).self) { resolver in
            GameServiceImpl(gameRepository: resolver.resolve((any GameRepository).self)!)
        }
        container.register((any UserService).self) { resolver in
            UserServiceImpl(
                userRepository: resolver.resolve((any UserRepository).self)!,
                jwtProvider: resolver.resolve((any JwtProvider).self)!
            )
        }
        container.register((any GameStatsService).self) { resolver in
            GameStatsServiceImpl(gameStatsRepository: resolver.resolve((any GameStatsRepository).self)!)
        }
        
        // Controllers
        container.register(GameController.self) { resolver in
            GameController(
                gameService: resolver.resolve((any GameService).self)!, gameStatsService: resolver.resolve((any GameStatsService).self)!
            )
        }
        container.register(UserController.self) { resolver in
            UserController(
                userService: resolver.resolve((any UserService).self)!
            )
        }
    }
}

