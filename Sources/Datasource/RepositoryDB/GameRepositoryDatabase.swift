//
//  GameRepositoryDatabase.swift
//  TicTacToe

import Foundation
import Domain
import Fluent
import Vapor

public final class GameRepositoryDatabase: GameRepository {
    private let db: any Database

    public init(db: any Database) {
        self.db = db
    }

    public func saveGame(_ domain: GameDomain) async throws {
        let gameData = MapperGameDataDomain.toData(domain)
        
        if let id = gameData.id {
            if let existing = try await GameData.find(id, on: db) {
                existing.grid = gameData.grid
                existing.state = gameData.state
                existing.players = gameData.players
                existing.withAI = gameData.withAI
                try await existing.update(on: db)
                return
            }
        }
        
        try await gameData.save(on: db)
    }

    public func getGame(by id: UUID) async -> GameDomain? {
        guard let gameData = try? await GameData.find(id, on: db) else {
            return nil
        }
        return MapperGameDataDomain.toDomain(gameData)
    }
    
    public func getAllGames() async -> [GameDomain] {
        do {
            let games = try await GameData.query(on: db)
                .all()
                .map { gameData in
                    return MapperGameDataDomain.toDomain(gameData)
                }
            return games
        } catch {
            return []
        }
    }

    public func deleteGame(by id: UUID) async {
        if let gameData = try? await GameData.find(id, on: db) {
            try? await gameData.delete(on: db)
        }
    }
}
