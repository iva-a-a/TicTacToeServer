//
//  GameService.swift
//  TicTacToe

public protocol GameService: Sendable {
    func updateGameState(for game: GameDomain) -> GameDomain
    func getNextMoveAI(for game: GameDomain) -> GameDomain
    func checkGameOver(for game: GameDomain) -> Bool
    func validateMove(for origGame: GameDomain, for newGame: GameDomain) -> Bool
}
