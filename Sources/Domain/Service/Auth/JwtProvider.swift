//
//  JwtProvider.swift
//  TicTacToe

import Vapor
import JWTKit

public protocol JwtProvider: Sendable {
    func generateAccessToken(userID: UUID) throws -> String
    func generateRefreshToken(userID: UUID) throws -> String

    func verifyAccessToken(_ token: String) throws -> ApiJwtPayload
    func verifyRefreshToken(_ token: String) throws -> ApiJwtPayload

    func getUserID(from token: String) throws -> UUID
    func getUserIDFromRefresh(_ token: String) throws -> UUID
}

