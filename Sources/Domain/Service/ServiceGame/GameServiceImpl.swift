//
//  GameServiceImpl.swift
//  TicTacToe

import Foundation

public class GameServiceImpl: GameService, @unchecked Sendable {
    
    private let gameRepository: any GameRepository

    public init(gameRepository: any GameRepository) {
        self.gameRepository = gameRepository
    }
    
    public func createGame(by playerId: UUID, creator: String, playWithAI: Bool) async throws -> GameDomain {
        let playerX = PlayerDomain(id: playerId, login: creator, tile: .x)
        let playerO = PlayerDomain(id: UUID(), tile: .o)
        let players = playWithAI ? [playerX, playerO] : [playerX]
        let state: GameStateDomain = players.count == 2 ? .playerTurn(playerX.id) : .waitingForPlayers

        let game = GameDomain(
            board: BoardDomain(),
            id: UUID(),
            state: state,
            players: players,
            withAI: playWithAI,
            dateСreation: Date()
        )

        try await gameRepository.saveGame(game)
        return game
    }

    public func joinGame(gameId: UUID, playerId: UUID, playerLogin: String) async throws -> GameDomain {
        guard var game = await gameRepository.getGame(by: gameId) else {
            throw GameError.gameNotFound
        }

        guard game.players.count == 1 else {
            throw GameError.invalidCountPlayers
        }

        let existingTile = game.players[0].tile
        let newTile: Tile = existingTile == .x ? .o : .x
        game.players.append(PlayerDomain(id: playerId, login: playerLogin, tile: newTile))
        game.state = .playerTurn(game.players[0].id)

        try await gameRepository.saveGame(game)
        return game
    }
    
    public func makeMove(gameId: UUID, playerId: UUID, row: Int, col: Int) async throws -> GameDomain {
        guard var game = await gameRepository.getGame(by: gameId) else {
            throw GameError.gameNotFound
        }
        guard case let .playerTurn(currentPlayerId) = game.state, currentPlayerId == playerId else {
            throw GameError.invalidMove
        }
        guard let currentPlayer = game.players.first(where: { $0.id == playerId }) else {
            throw GameError.invalidMove
        }
        guard game.board.isEmptyTile(row, col) else {
            throw GameError.invalidMove
        }
        game.board.grid[row][col] = currentPlayer.tile
        game = updateGameState(for: game)
        try await gameRepository.saveGame(game)

        if game.withAI {
            game = getNextMoveAI(for: game)
            try await gameRepository.saveGame(game)
        }
        return game
    }

    private func getNextMoveAI(for game: GameDomain) -> GameDomain {
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
    
    private func updateGameState(for game: GameDomain) -> GameDomain {
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
    
    public func getFinishedGames(for userId: UUID) async -> [GameDomain] {
        return await gameRepository.getFinishedGames(for: userId)
    }
    
    public func getGame(by id: UUID) async -> GameDomain? {
        return await gameRepository.getGame(by: id)
    }
    
    public func getAvailableGames(for playerId: UUID) async -> [GameDomain] {
        return await gameRepository.getAvailableGames(for: playerId)
    }

    public func getInProgressGames(for playerId: UUID) async -> [GameDomain] {
        return await gameRepository.getInProgressGames(for: playerId)
    }

}
