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
        
        if let id = gameData.id,
           let existing = try await GameData.find(id, on: db) {
            existing.grid = gameData.grid
            existing.state = gameData.state
            existing.playerXId = gameData.playerXId
            existing.playerOId = gameData.playerOId
            existing.playerXLogin = gameData.playerXLogin
            existing.playerOLogin = gameData.playerOLogin
            existing.currentTurnPlayerId = gameData.currentTurnPlayerId
            existing.winnerId = gameData.winnerId
            existing.isDraw = gameData.isDraw
            existing.withAI = gameData.withAI
            existing.dateСreation = gameData.dateСreation
            try await existing.update(on: db)
            return
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
    
    public func getFinishedGames(for userId: UUID) async -> [GameDomain] {
        do {
            let games = try await GameData.query(on: db)
                .group(.or) { or in
                    or.filter(\.$playerXId == userId)
                    or.filter(\.$playerOId == userId)
                }
                .filter(\.$state == .finished)
                .all()
            
            return games.map { MapperGameDataDomain.toDomain($0) }
        } catch {
            return []
        }
    }
    
    public func getAvailableGames(for playerId: UUID) async -> [GameDomain] {
        do {
            let games = try await GameData.query(on: db)
                .filter(\.$state == .waiting)
                .filter(\.$playerXId != playerId)
                .all()

            return games.map { MapperGameDataDomain.toDomain($0) }
        } catch {
            return []
        }
    }
    
    public func getInProgressGames(for playerId: UUID) async -> [GameDomain] {
        do {
            let games = try await GameData.query(on: db)
                .filter(\.$state == .inProgress)
                .group(.or) { or in
                    or.filter(\.$playerXId == playerId)
                    or.filter(\.$playerOId == playerId)
                }
                .all()

            return games.map { MapperGameDataDomain.toDomain($0) }
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
