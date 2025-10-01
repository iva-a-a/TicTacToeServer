//
//  CreateGame.swift
//  TicTacToe
//

import Foundation
import Fluent

public struct CreateGame: AsyncMigration {
    public init() {}
    
    public func prepare(on database: any Database) async throws {
        try await database.schema("games")
            .id()
            .field("grid", .json, .required)
            .field("state", .string, .required)
            .field("playerX_id", .uuid)
            .field("playerO_id", .uuid)
            .field("playerX_login", .string)
            .field("playerO_login", .string)
            .field("current_turn_player_id", .uuid)
            .field("winner_id", .uuid)
            .field("is_draw", .bool, .required)
            .field("withAI", .bool, .required)
            .field("created", .datetime, .required)
            .create()
    }
    
    public func revert(on database: any Database) async throws {
        try await database.schema("games").delete()
    }
}
