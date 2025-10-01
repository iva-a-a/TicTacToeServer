//
//  MapperJwtWebDomain.swift
//  TicTacToe

import Domain

public struct MapperJwtWebDomain {
    static func toDomain(_ req: JwtRequest) -> JwtAuthDomain {
        return JwtAuthDomain(login: req.login, password: req.password)
    }
    
    static func toDomain(_ req: JwtResponse) -> JwtTokensDomain {
        return JwtTokensDomain(accessToken: req.accessToken, refreshToken: req.refreshToken)
    }
    
    static func toDomain(_ req: RefreshJwtRequest) -> RefreshTokenDomain {
        return RefreshTokenDomain(refreshToken: req.refreshToken)
    }
    
    static func toWeb(_ domain: JwtAuthDomain) -> JwtRequest {
        return JwtRequest(login: domain.login, password: domain.password)
    }
    
    static func toWeb(_ domain: JwtTokensDomain) -> JwtResponse {
        JwtResponse(type: "Bearer", accessToken: domain.accessToken, refreshToken: domain.refreshToken)
    }
    
    static func toWeb(_ domain: RefreshTokenDomain) -> RefreshJwtRequest {
        return RefreshJwtRequest(refreshToken: domain.refreshToken)
    }
}
