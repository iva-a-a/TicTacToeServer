//
//  JoinGameRequest.swift
//  TicTacToe

import Foundation
import Vapor

public struct JoinGameRequest: Content {
    public let playerId: UUID
    public let playerLogin: String
    
    public init(playerId: UUID, playerLogin: String) {
        self.playerId = playerId
        self.playerLogin = playerLogin
    }
}
