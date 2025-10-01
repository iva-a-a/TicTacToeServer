//
//  UserService.swift
//  TicTacToe

import Foundation

public protocol UserService: Sendable {
    func register(req: JwtAuthDomain) async throws -> UUID
    func authorize(req: JwtAuthDomain) async throws -> JwtTokensDomain
    
    func refreshAccessToken(req: RefreshTokenDomain) async throws -> JwtTokensDomain
    func refreshRefreshToken(req: RefreshTokenDomain) async throws -> JwtTokensDomain
    
    func getUser(by id: UUID) async throws -> UserDomain?
}
