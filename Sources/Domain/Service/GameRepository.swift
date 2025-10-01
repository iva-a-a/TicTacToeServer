//
//  GameRepository.swift
//  TicTacToe

import Foundation

public protocol GameRepository: Sendable {
    func saveGame(_ domain: GameDomain) async throws
    
    func getGame(by id: UUID) async -> GameDomain?
    func getAllGames() async -> [GameDomain]
    func getFinishedGames(for userId: UUID) async -> [GameDomain]
    func getAvailableGames(for playerId: UUID) async -> [GameDomain]
    func getInProgressGames(for playerId: UUID) async -> [GameDomain] 
    
    func deleteGame(by id: UUID) async
}
