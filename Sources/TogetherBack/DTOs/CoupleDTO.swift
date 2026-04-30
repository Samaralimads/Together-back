//
//  CoupleDTO.swift
//  TogetherBack
//
//  Created by Samara Lima da Silva on 30/04/2026.
//

import Vapor

// MARK: - Join Request
struct JoinCoupleRequest: Content {
    let invitationCode: String
    let relationshipStartDate: String
}

// MARK: - Invitation Response
struct InvitationResponse: Content {
    let code: String
}

// MARK: - Couple Response
struct CoupleResponse: Content {
    let id: String
    let relationshipStartDate: String
    let partner: PartnerResponse
}

struct PartnerResponse: Content {
    let id: String
    let firstName: String
}
