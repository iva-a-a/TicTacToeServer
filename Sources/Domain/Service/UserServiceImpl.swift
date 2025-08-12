//
//  UserServiceImpl.swift
//  TicTacToe

import Foundation
import Vapor

public final class UserServiceImpl: UserService {
    private let userRepository: any UserRepository
    
    public init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }
    
    public func register(req: SignUpDomain) async throws {
        if try await userRepository.getUser(by: req.login) != nil {
            throw UserError.unavailableLogin
        }
        let user = UserDomain(id: UUID(), login: req.login, password: req.password)
        try await userRepository.createUser(user)
    }
    
    public func authorize(credentials: String) async throws -> UUID {
        guard let decoded = Data(base64Encoded: credentials),
              let credentials = String(data: decoded, encoding: .utf8),
              let sepIndex = credentials.firstIndex(of: ":") else {
            throw UserError.invalidCredentials
        }
        
        let login = credentials[..<sepIndex]
        let password = credentials[credentials.index(after: sepIndex)...]
        
        guard let user = try await userRepository.getUser(by: String(login)), user.password == String(password) else {
            throw UserError.invalidLoginOrPassword
        }
        return user.id
    }
    
    public func getUser(by id: UUID) async throws -> UserDomain? {
        try await userRepository.getUser(by: id)
    }
}
