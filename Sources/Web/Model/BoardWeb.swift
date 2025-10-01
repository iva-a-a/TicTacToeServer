//
//  BoardWeb.swift
//  TicTacToe

import Foundation
import Domain
import Vapor

public enum TileWeb: Int, Codable, Sendable {
    case empty = 0
    case x = 1
    case o = 2
}

public struct BoardWeb: Content {
    public var grid: [[TileWeb]]
    
    public init(grid: [[TileWeb]]) {
        self.grid = grid
    }
}
