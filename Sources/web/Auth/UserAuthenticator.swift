//
//  UserAuthenticator.swift
//  TicTacToe

import Vapor
import Domain

public struct UserAuthenticator: AsyncBasicAuthenticator {
    public typealias User = AuthorizedUser

    private let userService: any UserService

    public init(userService: any UserService) {
        self.userService = userService
    }

    public func authenticate(basic: BasicAuthorization, for request: Request) async throws {

        try UserValidator.validate(basic.username, basic.password)
        let credentialsString = "\(basic.username):\(basic.password)"
        guard let base64 = credentialsString.data(using: .utf8)?.base64EncodedString() else {
            throw AuthenticationError.invalidFormat
        }

        let userId = try await userService.authorize(credentials: base64)
        request.auth.login(AuthorizedUser(id: userId))
    }
}

public struct AuthorizedUser: Authenticatable {
    public let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}
