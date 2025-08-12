//
//  MapperWebDomain.swift
//  TicTacToe

import Foundation
import Domain

public struct MapperGameWebDomain {
    public static func toDomain(_ web: GameWeb) -> GameDomain {
        return GameDomain(
            board: MapperBoardWebDomain.toDomain(web.board),
            id: web.id,
            state: MapperGameStateWebDomain.toDomain(web.state),
            players: MapperPlayerWebDomain.toDomainList(web.players),
            withAI: web.withAI
        )
    }

    public static func toWeb(_ domain: GameDomain) -> GameWeb {
        return GameWeb(
            board: MapperBoardWebDomain.toWeb(domain.board),
            id: domain.id,
            state: MapperGameStateWebDomain.toWeb(domain.state),
            players: MapperPlayerWebDomain.toWebList(domain.players),
            withAI: domain.withAI
        )
    }
}

public struct MapperTileWebDomain {
    static func toDomain(_ web: TileWeb) -> Tile {
        switch web {
        case .empty: return .empty
        case .x: return .x
        case .o: return .o
        }
    }

    static func toWeb(_ domain: Tile) -> TileWeb {
        switch domain {
        case .empty: return .empty
        case .x: return .x
        case .o: return .o
        }
    }
}

public struct MapperBoardWebDomain {
    static func toDomain(_ board: BoardWeb) -> BoardDomain {
        let domainGrid = board.grid.map { row in
            row.map { MapperTileWebDomain.toDomain($0) }
        }
        return BoardDomain(grid: domainGrid)
    }
    
    public static func toWeb(_ board: BoardDomain) -> BoardWeb {
        let webGrid = board.grid.map { row in
            row.map { MapperTileWebDomain.toWeb($0) }
        }
        return BoardWeb(grid: webGrid)
    }
}

public struct MapperGameStateWebDomain {
    static func toDomain(_ web: GameStateWeb) -> GameStateDomain {
        switch web {
        case .waitingForPlayers: return .waitingForPlayers
        case .playerTurn(let id): return .playerTurn(id)
        case .draw: return .draw
        case .winner(let id): return .winner(id)
        }
    }

    static func toWeb(_ domain: GameStateDomain) -> GameStateWeb {
        switch domain {
        case .waitingForPlayers: return .waitingForPlayers
        case .playerTurn(let id): return .playerTurn(id)
        case .draw: return .draw
        case .winner(let id): return .winner(id)
        }
    }
}

public struct MapperPlayerWebDomain {
    static func toDomain(_ web: PlayerWeb) -> PlayerDomain {
        return PlayerDomain(id: web.id, tile: MapperTileWebDomain.toDomain(web.tile))
    }

    static func toWeb(_ domain: PlayerDomain) -> PlayerWeb {
        return PlayerWeb(id: domain.id, tile: MapperTileWebDomain.toWeb(domain.tile))
    }

    static func toDomainList(_ webList: [PlayerWeb]) -> [PlayerDomain] {
        return webList.map { toDomain($0) }
    }

    static func toWebList(_ domainList: [PlayerDomain]) -> [PlayerWeb] {
        return domainList.map { toWeb($0) }
    }
}
