//
//  ImportantDateDTO.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 13/05/2026.
//

import Vapor

// MARK: - Create / Update Request
struct ImportantDateRequest: Content {
    let label: String
    let date: String
}

// MARK: - Response
struct ImportantDateResponse: Content {
    let id: UUID
    let label: String
    let date: String

    init(from importantDate: ImportantDate) throws {
        self.id = try importantDate.requireID()
        self.label = importantDate.label

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        self.date = formatter.string(from: importantDate.date)
    }
}
