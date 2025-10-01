//
//  UserSignUpTests.swift
//  TicTacToe
//

import XCTest
import XCTVapor
@testable import App
import Domain
import Web
import Di

final class UserSignUpTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }

    override func tearDown() async throws {
        try? await app.asyncShutdown()
    }
    
    func testSuccessfulSignUp() throws {
        let mock = MockUserRepository(
            createHandler: { _ in },
            getByLoginHandler: { _ in nil }
        )
        app.userRepository = mock
        
        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: "newuser", password: "validPassword123"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(UserIdResponse.self)
            XCTAssertNotNil(response.id)
        }
    }

    func testSignUpWithShortLogin() throws {
        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: "ab", password: "validPassword123"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, AuthenticationError.invalidLogin.reason)
        }
    }

    func testSignUpWithShortPassword() throws {
        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: "validuser", password: "12345"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertContains(res.body.string, AuthenticationError.invalidPassword.reason)
        }
    }

    func testSignUpWithExistingLogin()  throws {

        let mock = MockUserRepository(
            createHandler: { _ in },
            getByLoginHandler: { _ in nil }
        )
        app.userRepository = mock

        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: "newuser", password: "validPassword123"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let signupResponse = try res.content.decode(UserIdResponse.self)
            XCTAssertNotNil(signupResponse.id)
        }

        try app.test(.POST, "/signup") { req in
            try req.content.encode(JwtRequest(login: "newuser", password: "validPassword"))
        } afterResponse: { res in
            XCTAssertEqual(res.status, .conflict)
            XCTAssertContains(res.body.string, UserError.unavailableLogin.reason)
        }
    }

    func testSignUpWithEmptyBody() throws {
        try app.test(.POST, "/signup", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: "{}")) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSignUpWithInvalidJSON() throws {
        try app.test(.POST, "/signup", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: "invalid json")) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSignUpWithMissingFields() throws {
        let invalidJson = """
        {
            "login": "testuser"
        }
        """
        
        try app.test(.POST, "/signup", headers: ["Content-Type": "application/json"], body: ByteBuffer(string: invalidJson)) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}

extension Application {
    struct UserRepositoryKey: StorageKey {
        typealias Value = UserRepository
    }
    
    var userRepository: UserRepository {
        get {
            guard let repo = storage[UserRepositoryKey.self] else {
                fatalError("UserRepository not configured")
            }
            return repo
        }
        set {
            storage[UserRepositoryKey.self] = newValue
        }
    }
}

final class MockUserRepository: @unchecked Sendable, UserRepository {
    private let createHandler: ((UserDomain) async throws -> Void)?
    private let getByLoginHandler: ((String) async throws -> UserDomain?)?
    private let getByIdHandler: ((UUID) async throws -> UserDomain?)?
    
    init(
        createHandler: ((UserDomain) async throws -> Void)? = nil,
        getByLoginHandler: ((String) async throws -> UserDomain?)? = nil,
        getByIdHandler: ((UUID) async throws -> UserDomain?)? = nil
    ) {
        self.createHandler = createHandler
        self.getByLoginHandler = getByLoginHandler
        self.getByIdHandler = getByIdHandler
    }
    
    func createUser(_ domain: UserDomain) async throws {
        if let handler = createHandler {
            try await handler(domain)
        }
    }
    
    func getUser(by login: String) async throws -> UserDomain? {
        if let handler = getByLoginHandler {
            return try await handler(login)
        }
        return nil
    }
    
    func getUser(by id: UUID) async throws -> UserDomain? {
        if let handler = getByIdHandler {
            return try await handler(id)
        }
        return nil
    }
}
