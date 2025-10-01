//
//  GameStatsRepository.swift
//  TicTacToe

public protocol GameStatsRepository: Sendable {
    func getTopPlayers(limit: Int) async throws -> [PlayerStatsDomain]
}
