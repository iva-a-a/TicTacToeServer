//
//  datasource/repository/gameRepositoryImpl.swift
//  TicTacToe

import Foundation
import domain

public class GameRepositoryImpl: GameRepository, @unchecked Sendable {
    private let store: GameStore
    
    public init(store: GameStore) {
        self.store = store
    }
    
    public func saveGame(_ game: GameDomain) async {
        await self.store.saveGame(MapperDtsDomain.toDts(game))
    }
    
    public func getGame(by id: UUID) -> GameDomain? {
        guard let gameDts = self.store.getGame(by: id) else {
            return nil
        }
        return MapperDtsDomain.toDomain(gameDts)
    }
    
    public func deleteGame(by id: UUID) {
        store.deleteGame(by: id)
    }
}
