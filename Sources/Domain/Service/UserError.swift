//
//  UserError.swift
//  TicTacToe

import Vapor

public enum UserError: AbortError {
    case unavailableLogin
    case invalidCredentials
    case invalidLoginOrPassword

    public var status: HTTPResponseStatus {
        switch self {
        case .unavailableLogin:
            return .conflict
        case .invalidCredentials, .invalidLoginOrPassword:
            return .unauthorized
        }
    }

    public var reason: String {
        switch self {
        case .unavailableLogin: return  "Login already taken"
        case .invalidCredentials: return  "Invalid authorization credentials"
        case .invalidLoginOrPassword: return  "Invalid login or password"
        }
    }
}

