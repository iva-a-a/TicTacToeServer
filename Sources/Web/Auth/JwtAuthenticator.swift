//
//  JwtAuthenticator.swift
//  TicTacToe

import Vapor
import Domain

public struct JwtAuthenticator: AsyncRequestAuthenticator {
    typealias User = AuthorizedUser
    private let jwtProvider: any JwtProvider

    public init(jwtProvider: any JwtProvider) {
        self.jwtProvider = jwtProvider
    }

    public func authenticate(request: Request) async throws {
        guard let bearer = request.headers.bearerAuthorization else {
            return
        }
        do {
            let userId = try jwtProvider.getUserID(from: bearer.token)
            request.auth.login(AuthorizedUser(id: userId))
        } catch {
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
    }
}

public struct AuthorizedUser: Authenticatable {
    public let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}

extension Request {
    func requireAuthorizedUser() throws -> AuthorizedUser {
        guard let user = auth.get(AuthorizedUser.self) else {
            throw Abort(.unauthorized, reason: "Unauthorized")
        }
        return user
    }
}

