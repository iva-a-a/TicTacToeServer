//
//  MapperGameDataDomain.swift
//  TicTacToe

import Foundation
import Domain

struct MapperGameDataDomain {
    static func toDomain(_ data: GameData) -> GameDomain {
        let tiles = data.grid.cells.map { row in
            row.map { Tile(rawValue: $0) ?? .empty }
        }

        let board = BoardDomain(grid: tiles)
        let state = MapperGameStateDataDomain.toDomain(data.state)
        let players = MapperPlayerDataDomain.toDomainList(data.players)

        return GameDomain(board: board, id: data.id ?? UUID(), state: state, players: players, withAI: data.withAI)
    }

    static func toData(_ domain: GameDomain) -> GameData {
        let intGrid = domain.board.grid.map { row in
            row.map { $0.rawValue }
        }

        let state = MapperGameStateDataDomain.toData(domain.state)
        let players = MapperPlayerDataDomain.toDataList(domain.players)

        return GameData(id: domain.id, grid: Grid(cells: intGrid), state: state, players: players, withAI: domain.withAI)
    }
}


public struct MapperGameStateDataDomain {
    static func toDomain(_ model: GameStateData) -> GameStateDomain {
        switch model {
        case .waitingForPlayers: return .waitingForPlayers
        case .playerTurn(let id): return .playerTurn(id)
        case .draw: return .draw
        case .winner(let id): return .winner(id)
        }
    }

    static func toData(_ domain: GameStateDomain) -> GameStateData {
        switch domain {
        case .waitingForPlayers: return .waitingForPlayers
        case .playerTurn(let id): return .playerTurn(id)
        case .draw: return .draw
        case .winner(let id): return .winner(id)
        }
    }
}

public struct MapperPlayerDataDomain {
    static func toDomain(_ model: PlayerData) -> PlayerDomain {
        return PlayerDomain(id: model.id, tile: Tile(rawValue: model.tile) ?? .empty)
    }

    static func toData(_ domain: PlayerDomain) -> PlayerData {
        return PlayerData(id: domain.id, tile: domain.tile.rawValue)
    }

    static func toDomainList(_ modelList: [PlayerData]) -> [PlayerDomain] {
        return modelList.map { toDomain($0) }
    }

    static func toDataList(_ domainList: [PlayerDomain]) -> [PlayerData] {
        return domainList.map { toData($0) }
    }
}
