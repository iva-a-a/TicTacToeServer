//
//  GameStatsRepositoryDatabase.swift
//  TicTacToe

import Domain
import Fluent
import Vapor
import SQLKit

public final class GameStatsRepositoryDatabase: GameStatsRepository {

    private let db: any Database

    public init(db: any Database) {
        self.db = db
    }
    
    public func getTopPlayers(limit: Int) async throws -> [PlayerStatsDomain] {
        let users = try await UserData.query(on: db).all()
        var stats: [PlayerStatsDomain] = []
        
        for user in users {
            guard let userId = user.id else { continue }
            
            let totalGames = try await GameData.query(on: db)
                .group(.or) { group in
                    group.filter(\.$playerXId == userId)
                    group.group(.and) { and in
                        and.filter(\.$playerOId == userId)
                        and.filter(\.$withAI == false)
                    }
                }
                .filter(\.$state == .finished)
                .count()

            let wins = try await GameData.query(on: db)
                .group(.and) { and in
                    and.filter(\.$winnerId == userId)
                    and.group(.or) { or in
                        or.filter(\.$playerXId == userId)
                        or.group(.and) { andO in
                            andO.filter(\.$playerOId == userId)
                            andO.filter(\.$withAI == false)
                        }
                    }
                }
                .count()
            
            guard totalGames > 0 else { continue }
            
            let ratio = Double(wins) / Double(totalGames)
            stats.append(PlayerStatsDomain(userId: userId, login: user.login, winRatio: ratio))
        }
        
        return stats.sorted(by: { $0.winRatio > $1.winRatio }).prefix(limit).map { $0 }
    }
}




