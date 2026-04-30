//
//  CoupleController.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 30/04/2026.
//

import Vapor
import Fluent
import SQLKit

struct CoupleController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let couples = routes.grouped("couples").grouped(JWTMiddleware())

        couples.get("me", "invitation", use: getMyInvitation)
        couples.post("join", use: joinCouple)
        couples.get("me", use: getMyCouple)
    }

    // MARK: - GET /couples/me/invitation
    @Sendable
    func getMyInvitation(req: Request) async throws -> InvitationResponse {
        let payload = try req.auth.require(UserPayload.self)
        guard let userId = UUID(uuidString: payload.userId) else {
            throw Abort(.unauthorized)
        }

        guard let invitation = try await Invitation.query(on: req.db)
            .filter(\.$userId == userId)
            .first()
        else {
            throw Abort(.notFound, reason: "No invitation found for this user.")
        }

        return InvitationResponse(code: invitation.invitationCode)
    }

    // MARK: - POST /couples/join
    @Sendable
    func joinCouple(req: Request) async throws -> CoupleResponse {
        let payload = try req.auth.require(UserPayload.self)
        let body = try req.content.decode(JoinCoupleRequest.self)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        guard let startDate = formatter.date(from: body.relationshipStartDate) else {
            throw Abort(.badRequest, reason: "Invalid date format. Expected YYYY-MM-DD.")
        }

        let formattedDate = formatter.string(from: startDate)

        guard let sql = req.db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database does not support raw SQL.")
        }

        try await sql.raw("""
            CALL create_couple_from_invitation(\(bind: body.invitationCode), \(bind: payload.userId), \(bind: formattedDate))
        """).run()

        return try await fetchCoupleForUser(userId: payload.userId, db: req.db, formatter: formatter)
    }

    // MARK: - GET /couples/me
    @Sendable
    func getMyCouple(req: Request) async throws -> CoupleResponse {
        let payload = try req.auth.require(UserPayload.self)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        return try await fetchCoupleForUser(userId: payload.userId, db: req.db, formatter: formatter)
    }

    // MARK: - Helpers
    private func fetchCoupleForUser(userId: String, db: any Database, formatter: DateFormatter) async throws -> CoupleResponse {
        guard let userUUID = UUID(uuidString: userId) else {
            throw Abort(.unauthorized)
        }

        let couples = try await Couple.query(on: db).all()

        guard let couple = couples.first(where: {
            $0.partner1Id == userUUID || $0.partner2Id == userUUID
        }) else {
            throw Abort(.notFound, reason: "You are not part of a couple yet.")
        }

        let partnerId = couple.partner1Id == userUUID ? couple.partner2Id : Optional(couple.partner1Id)

        guard let partnerId,
              let partner = try await User.find(partnerId, on: db)
        else {
            throw Abort(.notFound, reason: "Partner not found.")
        }

        return CoupleResponse(
            id: try couple.requireID().uuidString,
            relationshipStartDate: formatter.string(from: couple.relationshipStartDate),
            partner: PartnerResponse(
                id: try partner.requireID().uuidString,
                firstName: partner.firstName
            )
        )
    }
}
