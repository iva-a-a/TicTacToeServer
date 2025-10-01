//
//  GameData.swift
//  TicTacToe

import Foundation
import Fluent
import Vapor

public struct Grid: Codable, @unchecked Sendable  {
    var cells: [[Int]]
    
    public init(cells: [[Int]]) {
        self.cells = cells
    }
}

public enum GameStateData: String, Codable, @unchecked Sendable {
    case waiting
    case inProgress
    case finished
}

public final class GameData: Model, Content, @unchecked Sendable {
    public static let schema = "games"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "grid")
    public var grid: Grid

    @Enum(key: "state")
    public var state: GameStateData

    @OptionalField(key: "playerX_id")
    public var playerXId: UUID?

    @OptionalField(key: "playerO_id")
    public var playerOId: UUID?
    
    @OptionalField(key: "playerX_login")
    public var playerXLogin: String?

    @OptionalField(key: "playerO_login")
    public var playerOLogin: String?
    
    @OptionalField(key: "current_turn_player_id")
    public var currentTurnPlayerId: UUID?

    @OptionalField(key: "winner_id")
    public var winnerId: UUID?

    @Field(key: "is_draw")
    public var isDraw: Bool
    
    @Field(key: "withAI")
    public var withAI: Bool
    
    @Field(key: "created")
    public var dateСreation: Date
    

    public init() {}

    public init(id: UUID? = nil,
                grid: Grid,
                state: GameStateData,
                playerXId: UUID? = nil,
                playerOId: UUID? = nil,
                playerXLogin: String? = nil,
                playerOLogin: String? = nil,
                currentTurnPlayerId: UUID? = nil,
                winnerId: UUID? = nil,
                isDraw: Bool = false,
                withAI: Bool,
                dateСreation: Date) {
        self.id = id
        self.grid = grid
        self.state = state
        self.playerXId = playerXId
        self.playerOId = playerOId
        self.playerXLogin = playerXLogin
        self.playerOLogin = playerOLogin
        self.currentTurnPlayerId = currentTurnPlayerId
        self.winnerId = winnerId
        self.isDraw = isDraw
        self.withAI = withAI
        self.dateСreation = dateСreation
    }
}
