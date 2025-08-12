//
//  BoardWeb.swift
//  TicTacToe

import Foundation
import Domain
import Vapor

public enum TileWeb: Codable, Sendable {
    case empty
    case x
    case o

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "x": self = .x
        case "o": self = .o
        case " ", "empty": self = .empty
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid tile value: \(raw)"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .empty:
            try container.encode(" ")
        case .x:
            try container.encode("x")
        case .o:
            try container.encode("o")
        }
    }
}

public struct BoardWeb: Content {
    public var grid: [[TileWeb]]
    
    public init(grid: [[TileWeb]]) {
        self.grid = grid
    }
}
