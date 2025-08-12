//
//  GameServiceImpl.swift
//  TicTacToe

import Foundation

public class GameServiceImpl: GameService, @unchecked Sendable {
    
    public init() {}

    public func getNextMoveAI(for game: GameDomain) -> GameDomain {
        var updatedGame = game
        
        if case let .playerTurn(playerId) = game.state,
           game.players.contains(where: { $0.id == playerId && $0.tile == .o }) {
            let (_, row, col) = minimax(for: updatedGame, true, 0)
            if row != -1 && col != -1 {
                updatedGame.board.grid[row][col] = .o
                updatedGame = updateGameState(for: updatedGame)
            }
        }
        
        return updatedGame
    }
    
    private func minimax(for game: GameDomain,_ isMaximizing: Bool,_ depth: Int) -> (score: Int, row: Int, col: Int) {
        if checkWin(for: game, playerTile: .o) {
            return (100 - depth, -1, -1)
        }
        if checkWin(for: game, playerTile: .x) {
            return (depth - 100, -1, -1)
        }
        if game.board.isBoardFull() {
            return (0, -1, -1)
        }
        
        var bestScore = isMaximizing ? Int.min : Int.max
        var bestRow = -1
        var bestCol = -1
        
        for row in 0..<3 {
            for col in 0..<3 where game.board.isEmptyTile(row, col) {
                var newGame = game
                newGame.board.grid[row][col] = isMaximizing ? Tile.o : Tile.x
                let (score, _, _) = minimax(for: newGame, !isMaximizing, depth + 1)
                if isMaximizing {
                    if score > bestScore {
                        bestScore = score
                        bestRow = row
                        bestCol = col
                    }
                } else {
                    if score < bestScore {
                        bestScore = score
                        bestRow = row
                        bestCol = col
                    }
                }
            }
        }
        return (bestScore, bestRow, bestCol)
    }
    
    public func validateMove(for original: GameDomain, for new: GameDomain) -> Bool {
        guard case let .playerTurn(currentPlayerId) = original.state else {
            return false
        }
        guard let currentPlayer = original.players.first(where: { $0.id == currentPlayerId }) else {
            return false
        }
        var changes = 0
        for row in 0..<3 {
            for col in 0..<3 {
                if original.board.grid[row][col] != new.board.grid[row][col] {
                    guard original.board.grid[row][col] == .empty else { return false }

                    if new.board.grid[row][col] != currentPlayer.tile {
                        return false
                    }
                    changes += 1
                }
            }
        }
        return changes == 1
    }
    
    public func updateGameState(for game: GameDomain) -> GameDomain {
        var updatedGame = game
        if checkWin(for: game, playerTile: .o) {
            if let winner = game.players.first(where: { $0.tile == .o }) {
                updatedGame.state = .winner(winner.id)
            }
        } else if checkWin(for: game, playerTile: .x) {
            if let winner = game.players.first(where: { $0.tile == .x }) {
                updatedGame.state = .winner(winner.id)
            }
        } else if game.board.isBoardFull() {
            updatedGame.state = .draw
        } else {
            if case let .playerTurn(currentPlayerId) = game.state {
                if let currentIndex = game.players.firstIndex(where: { $0.id == currentPlayerId }),
                   game.players.count > 1 {
                    let nextIndex = (currentIndex + 1) % game.players.count
                    updatedGame.state = .playerTurn(game.players[nextIndex].id)
                }
            }
        }
        return updatedGame
    }

    public func checkGameOver(for game: GameDomain) -> Bool {
        return checkWin(for: game, playerTile: .o) || checkWin(for: game, playerTile: .x) || game.board.isBoardFull()
    }
    
    private func checkWin(for game: GameDomain, playerTile: Tile) -> Bool {
        let board = game.board.grid
        for i in 0..<3 {
            if (board[i][0] == playerTile && board[i][1] == playerTile && board[i][2] == playerTile) ||
               (board[0][i] == playerTile && board[1][i] == playerTile && board[2][i] == playerTile) {
                return true
            }
        }
        return (board[0][0] == playerTile && board[1][1] == playerTile && board[2][2] == playerTile) ||
               (board[0][2] == playerTile && board[1][1] == playerTile && board[2][0] == playerTile)
    }
}
