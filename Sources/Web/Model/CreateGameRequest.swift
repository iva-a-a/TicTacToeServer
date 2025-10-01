//
//  CreateGameRequest.swift
//  TicTacToe

import Foundation
import Vapor

public struct CreateGameRequest: Content {
    
    let creatorLogin: String
    let playWithAI: Bool
    
    public init(creatorLogin: String, playWithAI: Bool) {
        self.creatorLogin = creatorLogin
        self.playWithAI = playWithAI
    }
}



