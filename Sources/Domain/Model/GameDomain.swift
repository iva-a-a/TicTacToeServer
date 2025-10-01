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
    public var login: String?
    public var tile: Tile
    
    public init(id: UUID, login: String? = nil, tile: Tile) {
        self.id = id
        self.login = login
        self.tile = tile
    }
}

public struct GameDomain {
    public var board: BoardDomain
    public var id: UUID
    public var state: GameStateDomain
    public var players: [PlayerDomain]
    public var withAI: Bool
    public var dateСreation: Date
    
    public init(board: BoardDomain,
                id: UUID,
                state: GameStateDomain,
                players: [PlayerDomain],
                withAI: Bool,
                dateСreation: Date) {
        self.board = board
        self.id = id
        self.state = state
        self.players = players
        self.withAI = withAI
        self.dateСreation = dateСreation
    }
}
