//
//  UserModel.swift
//  TicTacToe

import Foundation
import Fluent
import Vapor

public final class UserData: Model, Content, @unchecked Sendable {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "login")
    public var login: String
    
    @Field(key: "password")
    public var password: String
    
    public init() { }
    
    public init(id: UUID? = nil, login: String, password: String) {
        self.id = id
        self.login = login
        self.password = password
    }
}
