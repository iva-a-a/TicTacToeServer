//
//  domain/service/gameServiceImpl.swift
//  TicTacToe


import Foundation

public class GameServiceImpl: GameService, @unchecked Sendable {
    
    public init() {}

    public func getNextMove(for game: GameDomain) -> GameDomain {
        var updatedGame = game
        let (_, row, col) = minimax(for: updatedGame, true, 0)
        if row != -1 && col != -1 {
            updatedGame.board.grid[row][col] = Tile.o
        }
        return updatedGame
    }
    
    private func minimax(for game: GameDomain,_ isMaximizing: Bool,_ depth: Int) -> (score: Int, row: Int, col: Int) {
        if isOWin(game) {
            return (100 - depth, -1, -1)
        }
        if isXWin(game) {
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

    

    public func validateMove(for origGame: GameDomain, for newGame: GameDomain) -> Bool {
        let origBoard = origGame.board.grid
        let newBoard = newGame.board.grid
        for row in 0..<3 {
            for col in 0..<3 {
                let original = origBoard[row][col]
                let new = newBoard[row][col]
                if original != Tile.empty && new != original {
                    return false
                }
            }
        }
        let allTiles = newBoard.flatMap { $0 }
        let countO = allTiles.filter { $0 == Tile.o }.count
        let countX = allTiles.filter { $0 == Tile.x }.count
        return countO + 1 == countX
    }
    
    public func isGameOver(_ game: GameDomain) -> Bool {
        return game.board.isBoardFull() || isWin(game)
    }
    
    private func isWin(_ game: GameDomain) -> Bool {
        return isRowColWin(game, Tile.o) || isRowColWin(game, Tile.x) || isDiaogonalWin(game, Tile.o) || isDiaogonalWin(game, Tile.x)
    }
    
    private func isRowColWin(_ game: GameDomain,_ player: Tile) -> Bool {
        if player == Tile.empty {
            return false
        }
        let board = game.board.grid
        for i in 0..<3 {
            if board[i][0] == player && isThreeTileEquals(board[i][0], board[i][1], board[i][2]) {
                return true
            }
            if board[0][i] == player && isThreeTileEquals(board[0][i], board[1][i], board[2][i]) {
                return true
            }
        }
        return false
    }
    
    private func isOWin(_ game: GameDomain) -> Bool {
        return isRowColWin(game, Tile.o) || isDiaogonalWin(game, Tile.o)
    }
    
    private func isXWin(_ game: GameDomain) -> Bool {
        return isRowColWin(game, Tile.x) || isDiaogonalWin(game, Tile.x)
    }
    
    private func isDiaogonalWin(_ game: GameDomain,_ player: Tile) -> Bool {
        if player == Tile.empty {
            return false
        }
        let board = game.board.grid
        return (isThreeTileEquals(board[0][0], board[1][1], board[2][2]) && board[0][0] == player) || (isThreeTileEquals(board[2][0], board[1][1], board[0][2]) && board[2][0] == player)
    }
    
    private func isThreeTileEquals(_ first: Tile, _ second: Tile, _ third: Tile) -> Bool {
        return first == second && second == third
    }
}
