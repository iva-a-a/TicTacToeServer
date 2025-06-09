//
//  domain/model/gameDomain.swift
//  TicTacToe

import Foundation

public struct GameDomain {
    public var board: BoardDomain
    public var id: UUID
    
    public init(board: BoardDomain, id: UUID) {
        self.board = board
        self.id = id
    }
}
