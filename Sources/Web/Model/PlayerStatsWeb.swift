//
//  PlayerStatsWeb.swift
//  TicTacToe

import Foundation
import Vapor

public struct PlayerStatsWeb: Content {
    public let userId: UUID
    public let login: String
    public let winRatio: Double
    
    public init(userId: UUID, login: String, winRatio: Double) {
        self.userId = userId
        self.login = login
        self.winRatio = winRatio
    }
}

public struct PlayersStatsWeb: Content {
    public let playersStats: [PlayerStatsWeb]
    
    public init(playersStats: [PlayerStatsWeb]) {
        self.playersStats = playersStats
    }
}
