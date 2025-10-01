//
//  JwtRequest.swift
//  TicTacToe

import Vapor

public struct JwtRequest: Content {
    public let login: String
    public let password: String
    
    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}

public struct JwtResponse: Content {
    public let type: String
    public let accessToken: String
    public let refreshToken: String
}

public struct RefreshJwtRequest: Content {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
