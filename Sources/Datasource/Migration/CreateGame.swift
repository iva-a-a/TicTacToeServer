//
//  CreateGame.swift
//  TicTacToe

import Foundation
import Fluent

public struct CreateGame: AsyncMigration {
    public init() {}
    
    public func prepare(on database: any Database) async throws {
        try await database.schema("games")
            .id()
            .field("grid", .json, .required)
            .field("state", .json, .required)
            .field("players", .json, .required)
            .field("withAI", .bool, .required)
            .create()
    }
    
    public func revert(on database: any Database) async throws {
        try await database.schema("games").delete()
    }
}
