//
//  web/mapper/mapperWebDomain.swift
//  TicTacToe

import Foundation
import domain

public struct MapperWebDomain {
    static func toDomain(_ web: GameWeb) -> GameDomain {
        return GameDomain(board: BoardDomain(grid: web.board.grid), id: web.id)
    }

    public static func toWeb(_ domain: GameDomain) async -> GameWeb {
        return GameWeb(board: BoardWeb(grid: domain.board.grid), id: domain.id)
    }
}
