//
//  UserController.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 29/04/2026.
//

import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")

        // Public routes
        users.post("register", use: register)
        users.post("login", use: login)

        // Protected routes
        let protected = users.grouped(JWTMiddleware())
        protected.get("me", use: me)
    }

    // MARK: - Register
    @Sendable
    func register(req: Request) async throws -> AuthResponse {
        let body = try req.content.decode(RegisterRequest.self)

        let existing = try await User.query(on: req.db)
            .filter(\.$email == body.email)
            .first()

        guard existing == nil else {
            throw Abort(.conflict, reason: "An account with this email already exists.")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        guard let birthDate = formatter.date(from: body.birthDate) else {
            throw Abort(.badRequest, reason: "Invalid birth_date format. Expected YYYY-MM-DD.")
        }

        let hashed = try Bcrypt.hash(body.password)
        let user = User(
            firstName: body.firstName,
            birthDate: birthDate,
            email: body.email,
            password: hashed
        )

        try await user.save(on: req.db)

        let token = try await generateToken(for: user, req: req)
        let userResponse = try UserResponse(from: user)
        return AuthResponse(token: token, user: userResponse)
    }

    // MARK: - Login
    @Sendable
    func login(req: Request) async throws -> AuthResponse {
        let body = try req.content.decode(LoginRequest.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$email == body.email)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }

        guard try Bcrypt.verify(body.password, created: user.password) else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }

        let token = try await generateToken(for: user, req: req)
        let userResponse = try UserResponse(from: user)
        return AuthResponse(token: token, user: userResponse)
    }

    // MARK: - Me (protected)
    @Sendable
    func me(req: Request) async throws -> UserResponse {
        let payload = try req.auth.require(UserPayload.self)

        guard
            let uuid = UUID(uuidString: payload.userId),
            let user = try await User.find(uuid, on: req.db)
        else {
            throw Abort(.notFound, reason: "User not found.")
        }

        return try UserResponse(from: user)
    }

    // MARK: - Helpers
    private func generateToken(for user: User, req: Request) async throws -> String {
        let payload = UserPayload(userId: try user.requireID().uuidString)
        return try await req.jwt.sign(payload)
    }
}
