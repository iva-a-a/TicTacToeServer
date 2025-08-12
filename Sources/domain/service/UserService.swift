//
//  UserService.swift
//  TicTacToe

import Foundation

public protocol UserService: Sendable {
    func register(req: SignUpDomain) async throws
    func authorize(credentials: String) async throws -> UUID
    func getUser(by id: UUID) async throws -> UserDomain?
}
