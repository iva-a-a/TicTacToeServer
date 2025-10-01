//
//  GamesResponse.swift
//  TicTacToe

import Foundation
import Vapor

public struct GamesResponse: Content {
    public let games: [GameWeb]
}
