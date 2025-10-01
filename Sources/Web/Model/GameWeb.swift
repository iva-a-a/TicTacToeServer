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
    public var login: String?
    public var tile: TileWeb

    public init(id: UUID, login: String? = nil, tile: TileWeb) {
        self.id = id
        self.login = login
        self.tile = tile
    }
}

public struct GameWeb: Content {
    public var id: UUID
    public var board: BoardWeb
    public var state: GameStateWeb
    public var players: [PlayerWeb]
    public var withAI: Bool
    public var dateСreation: String
    
    public init(id: UUID,
                board: BoardWeb,
                state: GameStateWeb,
                players: [PlayerWeb],
                withAI: Bool,
                dateСreation: String) {
        self.id = id
        self.board = board
        self.state = state
        self.players = players
        self.withAI = withAI
        self.dateСreation = dateСreation
    }
}
