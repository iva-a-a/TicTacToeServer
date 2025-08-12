//
//  ContainerProvider.swift
//  TicTacToe

import Swinject
import Domain
import Datasource
import Web
import Vapor

public final class ContainerProvider {
    @MainActor public static let shared = ContainerProvider()
    
    public let container: Container
    
    private init() {
        container = Container()
    }
    
    @MainActor public func setupDependencies(app: Application) {
        
        let db = app.db
        
        container.register((any GameRepository).self) { _ in
            GameRepositoryDatabase(db: db)
        }
        container.register((any UserRepository).self) { _ in
            UserRepositoryDatabase(db: db)
        }
        container.register((any GameService).self) { _ in
            GameServiceImpl()
        }
        container.register((any UserService).self) { resolver in
            UserServiceImpl(
                userRepository: resolver.resolve((any UserRepository).self)!
            )
        }
        container.register(GameController.self) { resolver in
            GameController(
                gameRepository: resolver.resolve((any GameRepository).self)!,
                gameService: resolver.resolve((any GameService).self)!
            )
        }
        container.register(UserController.self) { resolver in
            UserController(
                userService: resolver.resolve((any UserService).self)!
            )
        }
    }
}
