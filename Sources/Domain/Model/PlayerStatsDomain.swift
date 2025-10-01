//
//  PlayerStatsDomain.swift
//  TicTacToe

import Foundation

public struct PlayerStatsDomain: Sendable {
    public let userId: UUID
    public let login: String
    public let winRatio: Double
    
    public init(userId: UUID, login: String, winRatio: Double) {
        self.userId = userId
        self.login = login
        self.winRatio = winRatio
    }
}
