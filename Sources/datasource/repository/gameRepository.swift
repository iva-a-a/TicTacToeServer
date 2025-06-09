//
//  datasource/repository/gameRepository.swift
//  TicTacToe

import Foundation
import domain

public protocol GameRepository: Sendable {
    func saveGame(_ game: GameDomain) async
    func getGame(by id: UUID) -> GameDomain?
    func deleteGame(by id: UUID)
}

