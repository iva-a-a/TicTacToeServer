//
//  MapperUserDataDomain.swift
//  TicTacToe

import Foundation
import Domain

struct MapperUserDataDomain {
    static func toDomain(_ model: UserData) -> UserDomain {
        return UserDomain(id: model.id ?? UUID(), login: model.login, password: model.password)
    }

    static func toData(_ domain: UserDomain) -> UserData {
        return UserData(id: domain.id, login: domain.login, password: domain.password)
    }
}

