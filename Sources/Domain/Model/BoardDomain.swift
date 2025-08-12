//
//  BoardDomain.swift
//  TicTacToe

import Foundation

public enum Tile: Int, Codable, Sendable {
    case empty = 0
    case x = 1
    case o = 2
}

public struct BoardDomain {
    public var grid: [[Tile]]
    
    public init(grid: [[Tile]]) {
        self.grid = grid
    }
    
    public init() {
        grid = Array(repeating: Array(repeating: .empty, count: 3), count: 3)
    }
    
    public func isEmptyTile(_ row: Int, _ col: Int) -> Bool {
        guard row >= 0 && row < 3 && col >= 0 && col < 3 else {
            return false
        }
        return grid[row][col] == .empty
    }
    
    public func isBoardFull() -> Bool {
        for row in 0..<3 {
            for col in 0..<3 {
                if isEmptyTile(row, col) {
                    return false
                }
            }
        }
        return true
    }
}
