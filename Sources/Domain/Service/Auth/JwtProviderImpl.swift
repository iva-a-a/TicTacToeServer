//
//  JwtProviderImpl.swift
//  TicTacToe

import Foundation
@preconcurrency import JWTKit
import Vapor

public final class JwtProviderImpl: JwtProvider {
    private let signer: JWTSigner
    private let accessTTL: TimeInterval
    private let refreshTTL: TimeInterval

    public init(secret: String, accessTTL: TimeInterval = 3600, refreshTTL: TimeInterval = 604800) {
        self.signer = .hs256(key: secret)
        self.accessTTL = accessTTL
        self.refreshTTL = refreshTTL
    }

    public func generateAccessToken(userID: UUID) throws -> String {
        let payload = ApiJwtPayload(
            expiration: .init(value: Date().addingTimeInterval(accessTTL)),
            subject: .init(value: userID.uuidString)
        )
        return try signer.sign(payload)
    }

    public func generateRefreshToken(userID: UUID) throws -> String {
        let payload = ApiJwtPayload(
            expiration: .init(value: Date().addingTimeInterval(refreshTTL)),
            subject: .init(value: userID.uuidString)
        )
        return try signer.sign(payload)
    }

    public func verifyAccessToken(_ token: String) throws -> ApiJwtPayload {
        return try signer.verify(token, as: ApiJwtPayload.self)
    }

    public func verifyRefreshToken(_ token: String) throws -> ApiJwtPayload {
        return try signer.verify(token, as: ApiJwtPayload.self)
    }

    public func getUserID(from token: String) throws -> UUID {
        do {
            let payload = try verifyAccessToken(token)
            guard let uuid = UUID(uuidString: payload.subject.value) else {
                throw AuthenticationError.invalidSubject
            }
            return uuid
        } catch {
            throw AuthenticationError.invalidAccessToken
        }
    }
    
    public func getUserIDFromRefresh(_ token: String) throws -> UUID {
        do {
            let payload = try verifyRefreshToken(token)
            guard let uuid = UUID(uuidString: payload.subject.value) else {
                throw AuthenticationError.invalidSubject
            }
            return uuid
        } catch {
            throw AuthenticationError.invalidRefreshToken
        }
    }
}
