//
//  AiReview.swift
//  Vibe
//

import Foundation

// MARK: - Persona Style
enum PersonaStyle: String, Codable, CaseIterable {
    case encourage, critical, professional, casual, roast

    var label: String {
        switch self {
        case .encourage:    return "鼓励"
        case .critical:     return "批判"
        case .professional: return "专业"
        case .casual:       return "随意"
        case .roast:        return "毒舌"
        }
    }

    var icon: String {
        switch self {
        case .encourage:    return "sun.max.fill"
        case .critical:     return "exclamationmark.bubble.fill"
        case .professional: return "text.magnifyingglass"
        case .casual:       return "face.smiling"
        case .roast:        return "flame.fill"
        }
    }
}

// MARK: - AiPersona
struct AiPersona: Codable, Identifiable, Hashable {
    let id: UInt64
    var name: String
    var persona: String
    var style: PersonaStyle
    var enabled: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, persona, style, enabled
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - ReviewStatus
enum ReviewStatus: String, Codable {
    case pending, done, failed
}

// MARK: - AiReview
struct AiReview: Codable, Identifiable, Hashable {
    let id: UInt64
    let recordID: UInt64
    let personaID: UInt64
    let personaName: String
    var content: String
    var score: Int?
    var status: ReviewStatus
    var errorMsg: String?
    let createdAt: String
    var completedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, content, score, status
        case recordID = "record_id"
        case personaID = "persona_id"
        case personaName = "persona_name"
        case errorMsg = "error_msg"
        case createdAt = "created_at"
        case completedAt = "completed_at"
    }
}
