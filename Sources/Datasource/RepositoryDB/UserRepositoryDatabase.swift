//
//  UserRepositoryDatabase.swift
//  TicTacToe

import Foundation
import Domain
import Fluent
import Vapor

public final class UserRepositoryDatabase: UserRepository {
    private let db: any Database

    public init(db: any Database) {
        self.db = db
    }
    
    public func createUser(_ domain: UserDomain) async throws {
        try await MapperUserDataDomain.toData(domain).save(on: db)
    }
    
    public func getUser(by login: String) async throws -> UserDomain? {
        guard let userData = try await UserData.query(on: db)
            .filter(\.$login == login)
            .first() else {
            return nil
        }
        return MapperUserDataDomain.toDomain(userData)
    }

    public func getUser(by id: UUID) async throws -> UserDomain? {
        guard let userData = try await UserData.find(id, on: db) else {
            return nil
        }
        return MapperUserDataDomain.toDomain(userData)
    }
}
