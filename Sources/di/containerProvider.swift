//
//  di/containerProvider.swift
//  TicTacToe

import Swinject
import domain
import datasource
import web

public final class ContainerProvider {
    @MainActor public static let shared = ContainerProvider()
     
     public let container: Container
     
     private init() {
         container = Container()
         setupDependencies()
     }
     
     private func setupDependencies() {

         container.register(GameStore.self) { _ in
             GameStore()
         }.inObjectScope(.container)

         container.register((any GameRepository).self) { resolver in
             GameRepositoryImpl(store: resolver.resolve(GameStore.self)!)
         }

         container.register((any GameService).self) { _ in
             GameServiceImpl()
         }
         
         container.register(GameController.self) { resolver in
             GameController(
                gameRepository: resolver.resolve((any GameRepository).self)!,
                gameService: resolver.resolve((any GameService).self)!
             )
         }
     }
}
