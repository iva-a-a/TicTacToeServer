//
//  web/model/gameWeb.swift
//  TicTacToe
import Foundation
import Vapor

public struct GameWeb: Content {
    public var board: BoardWeb
    public var id: UUID
    
    public init(board: BoardWeb, id: UUID) {
        self.board = board
        self.id = id
    }
}
