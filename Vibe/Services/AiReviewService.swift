//
//  AiReviewService.swift
//  Vibe
//

import Foundation

class AiReviewService {
    static let shared = AiReviewService()
    private init() {}

    // MARK: - Reviews

    /// 获取某条记录的 AI 评价
    func getReviews(recordID: UInt64) async throws -> [AiReview] {
        try await APIClient.shared.request("/records/\(recordID)/reviews")
    }

    /// 重试失败的
    func retryReviews(recordID: UInt64) async throws {
        let _: Empty = try await APIClient.shared.request("/records/\(recordID)/reviews/retry", method: "POST")
    }

    // MARK: - Personas

    /// 获取人设列表（首次调用会自动创建默认人设）
    func listPersonas() async throws -> [AiPersona] {
        try await APIClient.shared.request("/personas")
    }

    struct CreatePersonaBody: Encodable {
        let name: String
        let persona: String
        let style: String
        let enabled: Bool
    }

    func createPersona(name: String, persona: String, style: PersonaStyle, enabled: Bool = true) async throws -> AiPersona {
        let body = CreatePersonaBody(name: name, persona: persona, style: style.rawValue, enabled: enabled)
        return try await APIClient.shared.request("/personas", method: "POST", body: body)
    }

    func updatePersona(id: UInt64, name: String, persona: String, style: PersonaStyle, enabled: Bool) async throws -> AiPersona {
        let body = CreatePersonaBody(name: name, persona: persona, style: style.rawValue, enabled: enabled)
        return try await APIClient.shared.request("/personas/\(id)", method: "PUT", body: body)
    }

    func deletePersona(id: UInt64) async throws {
        let _: Empty = try await APIClient.shared.request("/personas/\(id)", method: "DELETE")
    }
}
