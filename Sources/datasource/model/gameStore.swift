//
//  datasource/model/gameStore.swift
//  TicTacToe

import Foundation

public final class GameStore: @unchecked Sendable  {
    private var games: [UUID:GameDts] = [:]
    private let queue = DispatchQueue(label: "tictactoe-gamestore", attributes: .concurrent)
    
    public init() {}
    
    public func saveGame(_ game: GameDts) {
        queue.async(flags: .barrier) {
            self.games[game.id] = game
        }
    }
    
    public func getGame(by id: UUID) -> GameDts? {
        queue.sync {
            return self.games[id]
        }
    }
    
    public func deleteGame(by id: UUID) {
        self.games.removeValue(forKey: id)
    }
}
