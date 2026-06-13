//
//  MiscServices.swift
//  Vibe
//

import Foundation

class TagService {
    static let shared = TagService()
    private init() {}

    func list() async throws -> [Tag] {
        try await APIClient.shared.request("/tags")
    }

    func delete(id: UInt64) async throws {
        let _: APIResponse<Empty> = try await APIClient.shared.request("/tags/\(id)", method: "DELETE")
    }
}

class UploadService {
    static let shared = UploadService()
    private init() {}

    func upload(data: Data, fileName: String, mimeType: String, type: String) async throws -> UploadResult {
        try await APIClient.shared.upload(fileData: data, fileName: fileName, mimeType: mimeType, type: type)
    }
}

class LinkService {
    static let shared = LinkService()
    private init() {}

    struct PreviewReq: Encodable { let url: String }

    func preview(url: String) async throws -> LinkPreviewResult {
        try await APIClient.shared.request("/link-preview", method: "POST", body: PreviewReq(url: url))
    }
}

class StatsService {
    static let shared = StatsService()
    private init() {}

    func get() async throws -> StatsResponse {
        try await APIClient.shared.request("/stats")
    }
}
