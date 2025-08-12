//
//  GameController.swift
//  TicTacToe

import Vapor
import Domain
import Datasource

public struct GameResponse: Content {
    public let game: GameWeb
    public var message: String?
}

public struct CreateGameRequest: Content {
    let playWithAI: Bool
    
    public init(playWithAI: Bool) {
        self.playWithAI = playWithAI
    }
}

public struct JoinGameRequest: Content {
    public let playerId: UUID
    
    public init(playerId: UUID) {
        self.playerId = playerId
    }
}

public final class GameController: Sendable {
    private let gameRepository: any GameRepository
    private let gameService: any GameService
    
    public init(gameRepository: any GameRepository, gameService: any GameService) {
        self.gameRepository = gameRepository
        self.gameService = gameService
    }

    public func createGame(req: Request) async throws -> GameResponse {
        guard let currentUserId = req.auth.get(AuthorizedUser.self)?.id else {
            throw GameError.invalidAuthorizedUser
        }
        
        let createRequest = try req.content.decode(CreateGameRequest.self)
        
        let playerX = PlayerDomain(id: currentUserId, tile: .x)
        let playerO = PlayerDomain(id: UUID(), tile: .o)
        
        let players = createRequest.playWithAI ? [playerX, playerO] : [playerX]
        let gameWithAI = createRequest.playWithAI
        
        let gameId = UUID()
        let state: GameStateDomain = players.count == 2 ? .playerTurn(playerX.id) : .waitingForPlayers

        let game = GameDomain(board: BoardDomain(), id: gameId, state: state, players: players, withAI: gameWithAI)

        try await gameRepository.saveGame(game)
        
        return GameResponse(game: MapperGameWebDomain.toWeb(game), message: "Game created")
    }

    public func getAvailableGames(req: Request) async throws -> [GameWeb] {
        let games = await gameRepository.getAllGames()
        guard let currentUserId = req.auth.get(AuthorizedUser.self)?.id else {
            throw GameError.invalidAuthorizedUser
        }
        let available = games.filter { game in
            game.state == .waitingForPlayers && game.players.count == 1 &&
            !game.players.contains(where: { $0.id == currentUserId })
        }
        return available.map(MapperGameWebDomain.toWeb)
    }

    public func getGame(req: Request) async throws -> GameWeb {
        guard let gameId = req.parameters.get("gameId", as: UUID.self) else {
            throw GameError.invalidGameId
        }
        guard let game = await gameRepository.getGame(by: gameId) else {
            throw GameError.gameNotFound
        }
        return MapperGameWebDomain.toWeb(game)
    }

    public func joinGame(req: Request) async throws -> GameResponse {
        guard let gameId = req.parameters.get("gameId", as: UUID.self) else {
            throw GameError.invalidGameId
        }

        let data = try req.content.decode(JoinGameRequest.self)
        guard var game = await gameRepository.getGame(by: gameId) else {
            throw GameError.gameNotFound
        }

        guard game.players.count == 1 else {
            throw GameError.invalidCountPlayers
        }

        let existingTile = game.players[0].tile
        let newTile: Tile = existingTile == .x ? .o : .x
        let newPlayer = PlayerDomain(id: data.playerId, tile: newTile)

        game.players.append(newPlayer)
        game.state = .playerTurn(game.players[0].id)

        try await gameRepository.saveGame(game)
        return GameResponse(game: MapperGameWebDomain.toWeb(game), message: "Joined game")
    }

    public func makeMove(req: Request) async throws -> GameResponse {
        let gameId = try validateGameId(from: req)
        let incomingGame = try req.content.decode(GameWeb.self)
        try validateIncomingGame(incomingGame, gameId)

        var domainGame = MapperGameWebDomain.toDomain(incomingGame)
        let existingGame = await gameRepository.getGame(by: gameId)
        try validateExistingGame(existingGame: existingGame)
        
        try validateWithAIUnchanged(existingGame: existingGame!, incomingGame: domainGame)

        try validateMove(for: existingGame!, domainGame: domainGame)

        domainGame = gameService.updateGameState(for: domainGame)

        if gameService.checkGameOver(for: domainGame) {
            let message = getEndMessage(for: domainGame)
            return GameResponse(game: MapperGameWebDomain.toWeb(domainGame), message: message)
        }

        try await gameRepository.saveGame(domainGame)

        if domainGame.withAI {
            domainGame = gameService.getNextMoveAI(for: domainGame)

            if gameService.checkGameOver(for: domainGame) {
                let message = getEndMessage(for: domainGame)
                return GameResponse(game: MapperGameWebDomain.toWeb(domainGame), message: message)
            }
            try await gameRepository.saveGame(domainGame)
        }

        return GameResponse(game: MapperGameWebDomain.toWeb(domainGame), message: nil)
    }

    private func getEndMessage(for game: GameDomain) -> String {
        switch game.state {
        case .draw:
            return "Game over: Draw!"
            
        case .winner(let id):
            if let winner = game.players.first(where: { $0.id == id }) {
                if game.withAI && winner.tile == .o {
                    return "Game over: AI wins!"
                } else {
                    return "Game over: \(winner.id) wins!"
                }
            } else {
                return "Game over: Unknown winner"
            }
            
        default:
            return "Game over"
        }
    }

    private func validateGameId(from req: Request) throws -> UUID {
        guard let gameId = req.parameters.get("gameId", as: UUID.self) else {
            throw GameError.invalidGameId
        }
        return gameId
    }

    private func validateIncomingGame(_ incomingGame: GameWeb, _ gameId: UUID) throws {
        guard incomingGame.id == gameId else {
            throw GameError.gameIdMismatch
        }
    }

    private func validateExistingGame(existingGame: GameDomain?) throws {
        guard existingGame != nil else {
            throw GameError.gameNotFound
        }
    }

    private func validateMove(for existingGame: GameDomain, domainGame: GameDomain) throws {
        if !gameService.validateMove(for: existingGame, for: domainGame) {
            throw GameError.invalidMove
        }
    }
    
    private func validateWithAIUnchanged(existingGame: GameDomain, incomingGame: GameDomain) throws {
        if existingGame.withAI != incomingGame.withAI {
            throw GameError.invalidWithAIChange
        }
    }
}
