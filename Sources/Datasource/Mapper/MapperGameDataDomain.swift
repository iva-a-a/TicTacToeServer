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
        
        let state = MapperGameStateDataDomain.toDomain(state: data.state,
                                                       currentTurnPlayerId: data.currentTurnPlayerId,
                                                       winnerId: data.winnerId,
                                                       isDraw: data.isDraw)
        let players = MapperPlayerDataDomain.toDomainList(playerXId: data.playerXId,
                                                          playerOId: data.playerOId,
                                                          playerXLogin: data.playerXLogin,
                                                          playerOLogin: data.playerOLogin)
        return GameDomain(board: board,
                          id: data.id ?? UUID(),
                          state: state,
                          players: players,
                          withAI: data.withAI,
                          dateСreation: data.dateСreation)
    }

    static func toData(_ domain: GameDomain) -> GameData {
        let intGrid = domain.board.grid.map { row in
            row.map { $0.rawValue }
        }
        
        let (state, currentTurnPlayerId, winnerId, isDraw) = MapperGameStateDataDomain.toData(domain.state)
        
        let (playerXId, playerOId, playerXLogin, playerOLogin) = MapperPlayerDataDomain.toDataList(domain.players)
        
        return GameData(id: domain.id,
                        grid: Grid(cells: intGrid),
                        state: state,
                        playerXId: playerXId,
                        playerOId: playerOId,
                        playerXLogin: playerXLogin,
                        playerOLogin: playerOLogin,
                        currentTurnPlayerId: currentTurnPlayerId,
                        winnerId: winnerId,
                        isDraw: isDraw,
                        withAI: domain.withAI,
                        dateСreation: domain.dateСreation)
    }
}


public struct MapperGameStateDataDomain {
    static func toDomain(state: GameStateData,
                         currentTurnPlayerId: UUID?,
                         winnerId: UUID?,
                         isDraw: Bool) -> GameStateDomain {
        switch state {
        case .waiting:
            return .waitingForPlayers
        case .inProgress:
            if let turnId = currentTurnPlayerId {
                return .playerTurn(turnId)
            } else {
                return .waitingForPlayers
            }
        case .finished:
            if isDraw {
                return .draw
            } else if let winnerId = winnerId {
                return .winner(winnerId)
            } else {
                return .draw
            }
        }
    }
    
    static func toData(_ domain: GameStateDomain) -> (GameStateData, UUID?, UUID?, Bool) {
        switch domain {
        case .waitingForPlayers:
            return (.waiting, nil, nil, false)
        case .playerTurn(let id):
            return (.inProgress, id, nil, false)
        case .draw:
            return (.finished, nil, nil, true)
        case .winner(let id):
            return (.finished, nil, id, false)
        }
    }
}

public struct MapperPlayerDataDomain {
    static func toDomainList(playerXId: UUID?, playerOId: UUID?, playerXLogin: String?, playerOLogin: String?) -> [PlayerDomain] {
        var result: [PlayerDomain] = []
        if let x = playerXId {
            result.append(PlayerDomain(id: x, login: playerXLogin, tile: .x))
        }
        if let o = playerOId {
            result.append(PlayerDomain(id: o, login: playerOLogin, tile: .o))
        }
        return result
    }

    static func toDataList(_ domainList: [PlayerDomain]) -> (UUID?, UUID?, String?, String?) {
        var xId: UUID? = nil
        var oId: UUID? = nil
        var xLogin: String? = nil
        var oLogin: String? = nil
        
        for player in domainList {
            switch player.tile {
            case .x:
                xId = player.id
                xLogin = player.login
            case .o:
                oId = player.id
                oLogin = player.login
            default:
                break
            }
        }
        return (xId, oId, xLogin, oLogin)
    }
}
