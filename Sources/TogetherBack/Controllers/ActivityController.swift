//
//  ActivityController.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 30/04/2026.
//

import Vapor
import Fluent

struct ActivityController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let activities = routes.grouped("activities")
        let categories = routes.grouped("categories")

        // Public routes 
        activities.get(use: list)
        activities.get(":activityId", use: detail)
        categories.get(use: listCategories)
    }

    // MARK: - GET /activities
    // Supports query params: category, search, budget, duration, location
    @Sendable
    func list(req: Request) async throws -> [ActivityResponse] {
        var query = Activity.query(on: req.db)

        // Filter by category name
        if let categoryName = req.query[String.self, at: "category"] {
            let category = try await Category.query(on: req.db)
                .filter(\.$name == categoryName)
                .first()
            if let category {
                let categoryId = try category.requireID()
                query = query.filter(\.$categoryId == categoryId)
            }
        }

        // Filter by location: INDOORS or OUTDOORS
        if let location = req.query[String.self, at: "location"] {
            switch location.uppercased() {
            case "INDOORS":  query = query.filter(\.$isIndoor == true)
            case "OUTDOORS": query = query.filter(\.$isIndoor == false)
            default: break
            }
        }

        // Filter by budget: LOW, MEDIUM, HIGH
        if let budget = req.query[String.self, at: "budget"] {
            switch budget.uppercased() {
            case "LOW":    query = query.filter(\.$budget == "€")
            case "MEDIUM": query = query.filter(\.$budget == "€€")
            case "HIGH":   query = query.filter(\.$budget == "€€€")
            default: break
            }
        }

        // Filter by duration: < 2 HOURS, < 5 HOURS, 1 DAY, WEEKEND
        if let duration = req.query[String.self, at: "duration"] {
            switch duration.uppercased() {
            case "< 2 HOURS": query = query.filter(\.$duration <= 120)
            case "< 5 HOURS": query = query.filter(\.$duration <= 300)
            case "1 DAY":     query = query.filter(\.$duration <= 480)
            case "WEEKEND":   query = query.filter(\.$duration > 480)
            default: break
            }
        }

        let activities = try await query.all()

        // Filter by search term (in memory — fast enough at this scale)
        if let search = req.query[String.self, at: "search"], !search.isEmpty {
            let lowercased = search.lowercased()
            return try activities
                .filter { $0.title.lowercased().contains(lowercased) }
                .map { try ActivityResponse(from: $0) }
        }

        return try activities.map { try ActivityResponse(from: $0) }
    }

    // MARK: - GET /activities/:activityId
    @Sendable
    func detail(req: Request) async throws -> ActivityResponse {
        guard
            let idString = req.parameters.get("activityId"),
            let uuid = UUID(uuidString: idString),
            let activity = try await Activity.find(uuid, on: req.db)
        else {
            throw Abort(.notFound, reason: "Activity not found.")
        }

        return try ActivityResponse(from: activity)
    }

    // MARK: - GET /categories
    @Sendable
    func listCategories(req: Request) async throws -> [CategoryResponse] {
        let categories = try await Category.query(on: req.db).all()
        return try categories.map { try CategoryResponse(from: $0) }
    }
}
