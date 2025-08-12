//
//  AuthenticationError.swift
//  TicTacToe

import Vapor

public enum AuthenticationError: AbortError {
    case invalidFormat
    case invalidLogin
    case invalidPassword
    
    public var status: HTTPResponseStatus {
        return .unauthorized
    }

    public var reason: String {
        switch self {
        case .invalidFormat: return "Invalid credentials format"
        case .invalidLogin: return "Login must be at least 3 characters long"
        case .invalidPassword: return "Password must be at least 6 characters long"
        }
    }
}


