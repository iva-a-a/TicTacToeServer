//
//  GameError.swift
//  TicTacToe

import Vapor

public enum GameError: AbortError {
    case invalidMove
    case invalidCountPlayers
    case gameNotFound
    case invalidWithAIChange

    public var status: HTTPResponseStatus {
        switch self {
        case  .invalidMove, .invalidCountPlayers, .invalidWithAIChange:
            return .badRequest
        case .gameNotFound:
            return .notFound

        }
    }

    public var reason: String {
        switch self {
        case .invalidMove: return "Invalid move"
        case .invalidCountPlayers: return "Game already has two players"
        case .invalidWithAIChange: return "Changing 'withAI' during the game is not allowed"
        case .gameNotFound : return "Game not found"
        }
    }
}
