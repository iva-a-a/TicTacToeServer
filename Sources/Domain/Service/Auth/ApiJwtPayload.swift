//
//  ApiJwtPayload.swift
//  TicTacToe

import JWTKit
import Foundation

public struct ApiJwtPayload: JWTPayload {

    var expiration: ExpirationClaim
    var subject: SubjectClaim

    public func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
    
    public init(expiration: ExpirationClaim, subject: SubjectClaim) {
        self.expiration = expiration
        self.subject = subject
    }
}

