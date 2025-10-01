//
//  JwtDomainModels.swift
//  TicTacToe

import Foundation

public struct JwtAuthDomain {
    public let login: String
    public let password: String

    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}

public struct JwtTokensDomain {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public struct RefreshTokenDomain {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

