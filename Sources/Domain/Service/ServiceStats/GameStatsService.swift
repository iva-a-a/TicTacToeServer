//
//  StatsService.swift
//  TicTacToe

public protocol GameStatsService: Sendable {
    func getTopPlayers(limit: Int) async throws -> [PlayerStatsDomain]
}
