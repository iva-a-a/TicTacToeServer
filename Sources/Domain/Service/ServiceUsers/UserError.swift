//
//  UserError.swift
//  TicTacToe

import Vapor

public enum UserError: AbortError {
    case unavailableLogin
    case invalidLoginOrPassword
    case userNotFound

    public var status: HTTPResponseStatus {
        switch self {
        case .unavailableLogin:
            return .conflict
        case .invalidLoginOrPassword, .userNotFound:
            return .unauthorized
        }
    }

    public var reason: String {
        switch self {
        case .unavailableLogin: return  "Login already taken"
        case .invalidLoginOrPassword: return  "Invalid login or password"
        case .userNotFound: return  "User not found"
        }
    }
}

