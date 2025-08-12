//
//  GameData.swift
//  TicTacToe

import Foundation
import Fluent
import Vapor

public struct PlayerData: Codable, @unchecked Sendable {
    public var id: UUID
    public var tile: Int
    
    public init(id: UUID, tile: Int) {
        self.id = id
        self.tile = tile
    }
}

public struct PlayersData: Codable, @unchecked Sendable {
    let players: [PlayerData]
    
    public init(players: [PlayerData]) {
        self.players = players
    }
}

public struct Grid: Codable, @unchecked Sendable  {
    var cells: [[Int]]
}

public enum GameStateData: Codable, @unchecked Sendable {
    case waitingForPlayers
    case playerTurn(UUID)
    case draw
    case winner(UUID)
    
    private enum CodingKeys: CodingKey {
        case type, playerId
    }
    
    private enum StateType: String, Codable {
        case waitingForPlayers, playerTurn, draw, winner
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StateType.self, forKey: .type)
        switch type {
        case .waitingForPlayers: self = .waitingForPlayers
        case .draw: self = .draw
        case .playerTurn, .winner:
            let id = try container.decode(UUID.self, forKey: .playerId)
            self = type == .playerTurn ? .playerTurn(id) : .winner(id)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .waitingForPlayers:
            try container.encode(StateType.waitingForPlayers, forKey: .type)
        case .draw:
            try container.encode(StateType.draw, forKey: .type)
        case .playerTurn(let id):
            try container.encode(StateType.playerTurn, forKey: .type)
            try container.encode(id, forKey: .playerId)
        case .winner(let id):
            try container.encode(StateType.winner, forKey: .type)
            try container.encode(id, forKey: .playerId)
        }
    }
}

public final class GameData: Model, Content, @unchecked Sendable {
    public static let schema = "games"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "grid")
    public var grid: Grid

    @Field(key: "state")
    public var state: GameStateData

    @Field(key: "players")
    public var playersWrapper: PlayersData
    
    @Field(key: "withAI")
    public var withAI: Bool
    
    public var players: [PlayerData] {
        get { playersWrapper.players }
        set { playersWrapper = PlayersData(players: newValue) }
    }

    public init() {}

    public init(id: UUID? = nil, grid: Grid, state: GameStateData, players: [PlayerData], withAI: Bool) {
        self.id = id
        self.grid = grid
        self.state = state
        self.playersWrapper = PlayersData(players: players)
        self.withAI = withAI
    }
}
