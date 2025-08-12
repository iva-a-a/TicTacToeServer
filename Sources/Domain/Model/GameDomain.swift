//
//  GameDomain.swift
//  TicTacToe

import Foundation

public enum GameStateDomain: Codable, Sendable, Equatable {
    case waitingForPlayers
    case playerTurn(UUID)
    case draw
    case winner(UUID)
}

public struct PlayerDomain: Codable, Sendable {
    public var id: UUID
    public var tile: Tile
    
    public init(id: UUID, tile: Tile) {
        self.id = id
        self.tile = tile
    }
}

public struct GameDomain {
    public var board: BoardDomain
    public var id: UUID
    public var state: GameStateDomain
    public var players: [PlayerDomain]
    public var withAI: Bool
    
    public init(board: BoardDomain, id: UUID, state: GameStateDomain = .waitingForPlayers, players: [PlayerDomain] = [], withAI: Bool) {
        self.board = board
        self.id = id
        self.state = state
        self.players = players
        self.withAI = withAI
    }
}
