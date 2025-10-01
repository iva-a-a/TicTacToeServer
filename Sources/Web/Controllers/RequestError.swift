//
//  RequestError.swift
//  TicTacToe

import Vapor

public enum RequestError: AbortError {
    case invalidAuthorizedUser
    case invalidGameId
    case invalidUserId
    case gameNotFound
    case userNotFound
    case gameIdMismatch

    public var status: HTTPResponseStatus {
        switch self {
        case .invalidAuthorizedUser:
            return .unauthorized
        case .invalidGameId, .invalidUserId, .gameIdMismatch:
            return .badRequest
        case .gameNotFound, .userNotFound:
            return .notFound
        }
    }
    public var reason: String {
        switch self {
        case .invalidAuthorizedUser: return "User not authenticated"
        case .invalidGameId: return "Invalid game ID"
        case .gameNotFound: return "Game not found"
        case .invalidUserId: return "Invalid user ID"
        case .userNotFound: return "User not found"
        case .gameIdMismatch: return "Game ID in path and body mismatch"
        }
    }
}
