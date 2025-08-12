//
//  SignUpDomain.swift
//  TicTacToe

import Vapor

public struct SignUpDomain: Content {
    public var login: String
    public var password: String
    
    public init(_ login: String, _ password: String) {
        self.login = login
        self.password = password
    }
}
