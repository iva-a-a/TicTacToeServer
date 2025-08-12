//
//  configure.swift
//  TicTacToe

import Vapor
import Fluent
import FluentPostgresDriver
import Datasource

@MainActor public func configure(_ app: Application) async throws {

    // Настройка кодировщика/декодировщика
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    let dbName = app.environment == .testing ? "tictactoe_test" : (Environment.get("DB_NAME") ?? "tictactoe_db")

    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DB_HOST") ?? "localhost",
                username: Environment.get("DB_USER") ?? "postgres",
                password: Environment.get("DB_PASSWORD") ?? "postgres",
                database: dbName,
                tls: .disable
            )
        ), as: .psql
    )
    
    app.migrations.add(CreateGame())
    app.migrations.add(CreateUser())

    if app.environment == .testing {
        try await app.autoRevert().get()
    }

    // автоматическая миграция
    do {
        try await app.autoMigrate().get()
    } catch {
        print("Migration error:", String(reflecting: error))
        throw error
    }
    // Регистрация маршрутов
    try routes(app)
}
