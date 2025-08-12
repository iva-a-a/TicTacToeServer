//
//  UserValidator.swift
//  TicTacToe

import Vapor

public struct UserValidator {
    public static func validate(_ login: String, _ password: String) throws {
        guard login.count >= 3 else {
            throw AuthenticationError.invalidLogin
        }
        guard password.count >= 6 else {
            throw AuthenticationError.invalidPassword
        }
    }
}
