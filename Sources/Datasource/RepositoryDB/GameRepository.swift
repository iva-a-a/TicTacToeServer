//
//  GameRepository.swift
//  TicTacToe

import Foundation
import Domain

public protocol GameRepository: Sendable {
    func saveGame(_ domain: GameDomain) async throws
    func getGame(by id: UUID) async -> GameDomain?
    func getAllGames() async -> [GameDomain]
    func deleteGame(by id: UUID) async
}
