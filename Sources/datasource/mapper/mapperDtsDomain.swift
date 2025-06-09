//
//  datasource/mapper/mapperDtsDomain.swift
//  TicTacToe

import Foundation
import domain

struct MapperDtsDomain {
    static func toDomain(_ dts: GameDts) -> GameDomain {
        return GameDomain(board: BoardDomain(grid: dts.board.grid), id: dts.id)
    }

    static func toDts(_ domain: GameDomain) async -> GameDts {
        return GameDts(board: BoardDts(grid: domain.board.grid), id: domain.id)
    }
}

