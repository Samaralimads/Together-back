//
//  PlannedActivityDTO.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 30/04/2026.
//

import Vapor

// MARK: - Propose Request
struct ProposeActivityRequest: Content {
    let activityId: String
    let proposedDate: String
    let reminderEnabled: Bool
    let reminderDaysBefore: Int?
}

// MARK: - Decline Request
struct DeclineActivityRequest: Content {
    let note: String?
}

// MARK: - Reschedule Request
struct RescheduleActivityRequest: Content {
    let proposedDate: String        
    let note: String?
    let reminderEnabled: Bool
    let reminderDaysBefore: Int?
}

// MARK: - Planned Activity Response
struct PlannedActivityResponse: Content {
    let id: String
    let activityId: String
    let activityTitle: String
    let coupleId: String?
    let plannedByUserId: String
    let proposedDate: String
    let responseDate: String?
    let bookingStatus: String
    let reminderEnabled: Bool
    let reminderDaysBefore: Int?
    let note: String?
    let createdAt: String?
}
