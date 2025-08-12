//
//  UserController.swift
//  TicTacToe

import Vapor
import Domain

public struct UserAuthResponse: Content {
    public let userId: UUID
}

public struct UserResponse: Content {
    public let id: UUID
    public let login: String
}

public final class UserController: Sendable {
    private let userService: any UserService

    public init(userService: any UserService) {
        self.userService = userService
    }

    public func signUp(req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(SignUpRequest.self)
        try UserValidator.validate(request.login, request.password)
        try await userService.register(req: MapperSignUpWebDomain.toDomain(request))
        return .created
    }
    
    public func signIn(req: Request) async throws -> UserAuthResponse {
        guard let user = req.auth.get(AuthorizedUser.self) else {
            throw GameError.invalidAuthorizedUser
        }
        return UserAuthResponse(userId: user.id)
    }
    
    public func getUserById(req: Request) async throws -> UserResponse {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw GameError.invalidUserId
        }
        guard let user = try await userService.getUser(by: userId) else {
            throw GameError.userNotFound
        }
        return UserResponse(id: user.id, login: user.login)
    }
}
