//
//  UserRepository.swift
//  TicTacToe

import Foundation

public protocol UserRepository: Sendable {
    func createUser(_ domain: UserDomain) async throws
    func getUser(by login: String) async throws -> UserDomain?
    func getUser(by id: UUID) async throws -> UserDomain?
}
