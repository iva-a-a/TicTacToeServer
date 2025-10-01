//
//  AuthenticationError.swift
//  TicTacToe

import Vapor

public enum AuthenticationError: AbortError {
    case invalidLogin
    case invalidPassword
    case invalidSubject
    case invalidAccessToken
    case invalidRefreshToken
    
    public var status: HTTPResponseStatus {
        switch self {
        case .invalidSubject, .invalidAccessToken, .invalidRefreshToken: return .badRequest
        default: return .unauthorized
        }
    }

    public var reason: String {
        switch self {
        case .invalidLogin: return "Login must be at least 3 characters long"
        case .invalidPassword: return "Password must be at least 6 characters long"
        case .invalidSubject : return "Invalid subject in token"
        case .invalidAccessToken : return "Invalid access token"
        case .invalidRefreshToken: return "Invalid refresh token"
        }
    }
}


