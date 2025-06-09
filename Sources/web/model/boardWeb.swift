//
//  web/model/boardWeb.swift
//  TicTacToe
import Foundation
import domain
import Vapor

public struct BoardWeb: Content {
    public var grid: [[Tile]]
    
    public init(grid: [[Tile]]) {
        self.grid = grid
    }
}
