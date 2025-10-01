//
//  UserResponse.swift
//  TicTacToe

import Foundation
import Vapor

public struct UserResponse: Content {
    public let id: UUID
    public let login: String
}
