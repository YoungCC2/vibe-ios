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
        let path = "/tags/\(id)"
        guard let url = URL(string: APIClient.shared.baseURL + path) else {
            throw APIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = APIClient.shared.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.serverError(0, "删除失败")
        }
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
