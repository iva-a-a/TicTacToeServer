//
//  datasource/model/gameDts.swift
//  TicTacToe

import Foundation

public struct GameDts: Sendable {
    public var board: BoardDts
    public var id: UUID
    
    public init(board: BoardDts, id: UUID) {
        self.board = board
        self.id = id
    }
}
