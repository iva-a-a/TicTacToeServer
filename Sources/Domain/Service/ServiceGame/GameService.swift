//
//  GameService.swift
//  TicTacToe

import Foundation

public protocol GameService: Sendable {
    func createGame(by playerId: UUID, creator: String, playWithAI: Bool) async throws -> GameDomain
    func joinGame(gameId: UUID, playerId: UUID, playerLogin: String) async throws -> GameDomain
    func makeMove(gameId: UUID, playerId: UUID, row: Int, col: Int) async throws -> GameDomain
    func getFinishedGames(for userId: UUID) async -> [GameDomain]
    func getGame(by id: UUID) async -> GameDomain?
    func getAvailableGames(for playerId: UUID) async -> [GameDomain]
    func getInProgressGames(for playerId: UUID) async -> [GameDomain]
}
