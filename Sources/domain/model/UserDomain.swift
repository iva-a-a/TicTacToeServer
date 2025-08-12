//
//  UserDomain.swift
//  TicTacToe

import Foundation

public struct UserDomain {
    public let id: UUID
    public let login: String
    public let password: String
    
    public init(id: UUID, login: String, password: String) {
        self.id = id
        self.login = login
        self.password = password
    }
}
