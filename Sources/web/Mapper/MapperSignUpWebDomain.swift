//
//  MapperSignUpWebDomain.swift
//  TicTacToe

import Domain

public struct MapperSignUpWebDomain {
    static func toDomain(_ web: SignUpRequest) -> SignUpDomain {
        return SignUpDomain(web.login, web.password)
    }

    public static func toWeb(_ domain: SignUpDomain) async -> SignUpRequest {
        return SignUpRequest(domain.login, domain.password)
    }
}
