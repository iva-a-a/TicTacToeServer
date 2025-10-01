//
//  UserServiceImpl.swift
//  TicTacToe

import Foundation
import Vapor

public final class UserServiceImpl: UserService {
    private let userRepository: any UserRepository
    private let jwtProvider: any JwtProvider
    
    public init(userRepository: any UserRepository, jwtProvider: any JwtProvider) {
        self.userRepository = userRepository
        self.jwtProvider = jwtProvider
    }
    
    public func register(req: JwtAuthDomain) async throws -> UUID {
        try UserValidator.validate(req.login, req.password)
        if try await userRepository.getUser(by: req.login) != nil {
            throw UserError.unavailableLogin
        }
        let user = UserDomain(id: UUID(), login: req.login, password: req.password)
        try await userRepository.createUser(user)
        return user.id
    }
    
    public func getUser(by id: UUID) async throws -> UserDomain? {
        try await userRepository.getUser(by: id)
    }
    
    public func authorize(req: JwtAuthDomain) async throws -> JwtTokensDomain {
        guard let user = try await userRepository.getUser(by: req.login),
              user.password == req.password else {
            throw UserError.invalidLoginOrPassword
        }
        
        let accessToken = try jwtProvider.generateAccessToken(userID: user.id)
        let refreshToken = try jwtProvider.generateRefreshToken(userID: user.id)
        
        return JwtTokensDomain(accessToken: accessToken,refreshToken: refreshToken)
    }

    public func refreshAccessToken(req: RefreshTokenDomain) async throws -> JwtTokensDomain {
        let userId = try jwtProvider.getUserIDFromRefresh(req.refreshToken)
        guard let user = try await getUser(by: userId) else {
            throw UserError.userNotFound
        }
        let accessToken = try jwtProvider.generateAccessToken(userID: user.id)
        return JwtTokensDomain(accessToken: accessToken, refreshToken: req.refreshToken)
    }

    public func refreshRefreshToken(req: RefreshTokenDomain) async throws -> JwtTokensDomain {
        let userId = try jwtProvider.getUserIDFromRefresh(req.refreshToken)
        guard let user = try await getUser(by: userId) else {
            throw UserError.userNotFound
        }
        let accessToken = try jwtProvider.generateAccessToken(userID: user.id)
        let newRefreshToken = try jwtProvider.generateRefreshToken(userID: user.id)
        return JwtTokensDomain(accessToken: accessToken, refreshToken: newRefreshToken)
    }

}
