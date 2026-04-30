//
//  ActivityDTO.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 30/04/2026.
//

import Vapor

// MARK: - Category Response
struct CategoryResponse: Content {
    let id: String
    let name: String
    let imageUrl: String

    init(from category: Category) throws {
        self.id = try category.requireID().uuidString
        self.name = category.name
        self.imageUrl = category.imageUrl
    }
}

// MARK: - Activity Response
struct ActivityResponse: Content {
    let id: String
    let title: String
    let description: String
    let budget: String
    let duration: Int
    let isIndoor: Bool
    let categoryId: String

    init(from activity: Activity) throws {
        self.id = try activity.requireID().uuidString
        self.title = activity.title
        self.description = activity.description
        self.budget = activity.budget
        self.duration = activity.duration
        self.isIndoor = activity.isIndoor
        self.categoryId = activity.categoryId.uuidString
    }
}
