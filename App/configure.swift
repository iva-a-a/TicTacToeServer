//
// configure.swift
//  TicTacToe

import Vapor

@MainActor public func configure(_ app: Application) throws {
    try routes(app)

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)
}
