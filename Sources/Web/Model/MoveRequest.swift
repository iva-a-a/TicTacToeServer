//
//  MoveRequest.swift
//  TicTacToe

import Foundation
import Vapor

public struct MoveRequest: Content {
    public let playerId: UUID
    public let row: Int
    public let col: Int
    
    public init(playerId: UUID, row: Int, col: Int) {
        self.playerId = playerId
        self.row = row
        self.col = col
    }
}
