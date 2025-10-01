//
//  MapperPlayerStatsWebDomain.swift
//  TicTacToe

import Domain

public struct MapperPlayerStatsWebDomain {
    
    public static func toDomain(_ web: PlayerStatsWeb) -> PlayerStatsDomain {
        return PlayerStatsDomain(userId: web.userId, login: web.login, winRatio: web.winRatio)
    }
    
    public static func toWeb(_ domain: PlayerStatsDomain) -> PlayerStatsWeb {
        return PlayerStatsWeb(userId: domain.userId, login: domain.login, winRatio: domain.winRatio)
    }
}
