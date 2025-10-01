//
//  GameStatsServiceImpl.swift
//  TicTacToe

public final class GameStatsServiceImpl: GameStatsService {
    private let gameStatsRepository: any GameStatsRepository

    public init(gameStatsRepository: any GameStatsRepository) {
        self.gameStatsRepository = gameStatsRepository
    }

    public func getTopPlayers(limit: Int) async throws -> [PlayerStatsDomain] {
        try await gameStatsRepository.getTopPlayers(limit: limit)
    }
}
