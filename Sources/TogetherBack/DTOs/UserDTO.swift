//
//  UserDTO.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 29/04/2026.
//

import Vapor

// MARK: - Register
struct RegisterRequest: Content {
    let firstName: String
    let birthDate: String
    let email: String
    let password: String
}

// MARK: - Login
struct LoginRequest: Content {
    let email: String
    let password: String
}

// MARK: - Auth Response (returned on register & login)
struct AuthResponse: Content {
    let token: String
    let user: UserResponse
}

// MARK: - User Response
struct UserResponse: Content {
    let id: String
    let firstName: String
    let birthDate: String
    let email: String
    let profilePicture: String?

    init(from user: User) throws {
        self.id = try user.requireID().uuidString
        self.firstName = user.firstName
        self.email = user.email
        self.profilePicture = user.profilePicture

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        self.birthDate = formatter.string(from: user.birthDate)
    }
}
