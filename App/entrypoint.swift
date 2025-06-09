//
//  entrypoint.swift
//  TicTacToe

import Vapor
import di
import web
import Logging
import NIOCore
import NIOPosix

@main
struct AppEntry {
    static func main() async {
        var app: Application? = nil
        
        do {
            var env = try Environment.detect()
            try LoggingSystem.bootstrap(from: &env)
            
            app = try await Application.make(env)
            try configure(app!)
            try await app!.execute()
        } catch {
            print("Application error: \(error)")
            do {
                try await app?.asyncShutdown()
            } catch {
                print("Error during shutdown: \(error)")
            }
            exit(1)
        }
        do {
            try await app?.asyncShutdown()
        } catch {
            print("Error during shutdown: \(error)")
        }
    }
}
