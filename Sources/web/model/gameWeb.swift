//
//  GameWeb.swift
//  TicTacToe

import Foundation
import Vapor
import Domain

public enum GameStateWeb: Content, Equatable {
    case waitingForPlayers
    case playerTurn(UUID)
    case draw
    case winner(UUID)
}

public struct PlayerWeb: Content {
    public var id: UUID
    public var tile: TileWeb

    public init(id: UUID, tile: TileWeb) {
        self.id = id
        self.tile = tile
    }
}

public struct GameWeb: Content {
    public var board: BoardWeb
    public var id: UUID
    public var state: GameStateWeb
    public var players: [PlayerWeb]
    public var withAI: Bool
    
    public init(board: BoardWeb, id: UUID, state: GameStateWeb = .waitingForPlayers, players: [PlayerWeb] = [], withAI: Bool = false) {
        self.board = board
        self.id = id
        self.state = state
        self.players = players
        self.withAI = withAI
    }
}
