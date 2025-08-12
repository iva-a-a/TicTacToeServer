//
//  GameError.swift
//  TicTacToe

import Vapor

public enum GameError: AbortError {
    case invalidGameId
    case gameIdMismatch
    case gameNotFound
    case invalidMove
    case invalidCountPlayers
    case invalidAuthorizedUser
    case userNotFound
    case invalidUserId
    case invalidWithAIChange

    public var status: HTTPResponseStatus {
        switch self {
        case .invalidGameId, .gameIdMismatch, .invalidMove, .invalidCountPlayers, .invalidUserId, .invalidWithAIChange:
            return .badRequest
        case .gameNotFound, .userNotFound:
            return .notFound
        case .invalidAuthorizedUser:
            return .unauthorized
        }
    }

    public var reason: String {
        switch self {
        case .invalidGameId: return "Invalid game ID"
        case .gameIdMismatch: return "Game ID in path and body mismatch"
        case .gameNotFound: return "Game not found"
        case .invalidMove: return "Invalid move"
        case .invalidCountPlayers: return "Game already has two players"
        case .invalidAuthorizedUser: return "User not authenticated"
        case .userNotFound: return "User not found"
        case .invalidUserId: return "Invalid user ID"
        case .invalidWithAIChange: return "Changing 'withAI' during the game is not allowed"
        }
    }
}

