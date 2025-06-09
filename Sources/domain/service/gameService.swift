//
//  domain/service/gameService.swift
//  TicTacToe

public protocol GameService: Sendable {
    func getNextMove(for game: GameDomain) -> GameDomain
    func isGameOver(_ game: GameDomain) -> Bool
    func validateMove(for origGame: GameDomain, for newGame: GameDomain) -> Bool
}

