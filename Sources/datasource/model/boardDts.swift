//
//  datasource/model/boardDts.swift
//  TicTacToe

import Foundation
import domain

public struct BoardDts: Sendable {
    public var grid: [[Tile]]
    
    public init(grid: [[Tile]]) {
        self.grid = grid
    }
}
