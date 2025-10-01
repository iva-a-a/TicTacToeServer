//
//  UserController.swift
//  TicTacToe

import Vapor
import Domain

public final class UserController: Sendable {
    private let userService: any UserService

    public init(userService: any UserService) {
        self.userService = userService
    }

    public func signUp(req: Request) async throws -> UserIdResponse {
        let request = try req.content.decode(JwtRequest.self)
        let id = try await userService.register(req: MapperJwtWebDomain.toDomain(request))
        return UserIdResponse(id: id)
    }

    public func signIn(req: Request) async throws -> JwtResponse {
        let request = try req.content.decode(JwtRequest.self)
        let tokens = try await userService.authorize(req: MapperJwtWebDomain.toDomain(request))
        return MapperJwtWebDomain.toWeb(tokens)
    }

    public func refreshAccessToken(req: Request) async throws -> JwtResponse {
        let request = try req.content.decode(RefreshJwtRequest.self)
        let tokens = try await userService.refreshAccessToken(req: MapperJwtWebDomain.toDomain(request))
        return MapperJwtWebDomain.toWeb(tokens)
    }

    public func refreshRefreshToken(req: Request) async throws -> JwtResponse {
        let request = try req.content.decode(RefreshJwtRequest.self)
        let tokens = try await userService.refreshRefreshToken(req: MapperJwtWebDomain.toDomain(request))
        return MapperJwtWebDomain.toWeb(tokens)
    }
    
    public func getUserById(req: Request) async throws -> UserResponse {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw RequestError.invalidUserId
        }
        guard let user = try await userService.getUser(by: userId) else {
            throw RequestError.userNotFound
        }
        return UserResponse(id: user.id, login: user.login)
    }
    
    public func getMe(req: Request) async throws -> UserResponse {
        guard let authorizedUser = req.auth.get(AuthorizedUser.self) else {
            throw RequestError.userNotFound
        }
        guard let user = try await userService.getUser(by: authorizedUser.id) else {
            throw RequestError.userNotFound
        }
        return UserResponse(id: user.id, login: user.login)
    }
}
