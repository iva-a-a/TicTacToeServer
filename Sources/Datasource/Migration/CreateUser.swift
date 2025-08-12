//
//  CreateUser.swift
//  TicTacToe

import Foundation
import Fluent

public struct CreateUser: AsyncMigration {
    public init() {}
    
    public func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("login", .string, .required)
            .field("password", .string, .required)
            .unique(on: "login")
            .create()
    }
    
    public func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}

