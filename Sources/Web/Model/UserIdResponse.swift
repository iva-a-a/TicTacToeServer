//
//  UserIdResponse.swift
//  TicTacToe

import Foundation
import Vapor

public struct UserIdResponse: Content {
    public let id: UUID
}

