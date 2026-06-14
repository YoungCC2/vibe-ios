//
//  RecordService.swift
//  Vibe
//

import Foundation

class RecordService {
    static let shared = RecordService()
    private init() {}

    func list(page: Int = 1, pageSize: Int = 20, type: String? = nil, tag: String? = nil) async throws -> ([Record], Int64) {
        var query = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)"),
        ]
        if let type { query.append(URLQueryItem(name: "type", value: type)) }
        if let tag { query.append(URLQueryItem(name: "tag", value: tag)) }

        let resp: PaginatedData<Record> = try await APIClient.shared.request("/records", queryItems: query)
        return (resp.items, resp.total)
    }

    func get(id: UInt64) async throws -> Record {
        try await APIClient.shared.request("/records/\(id)")
    }

    struct CreateBody: Encodable {
        let type: String
        let content: String
        let tags: [String]
        let media_ids: [UInt64]
        var link_url: String?
        var link_title: String?
        var link_description: String?
        var link_domain: String?
        var link_thumbnail: String?
        var location_name: String?
    }

    func create(type: RecordType, content: String, tags: [String], mediaIDs: [UInt64], link: LinkInfo?, locationName: String? = nil) async throws -> Record {
        var body = CreateBody(type: type.rawValue, content: content, tags: tags, media_ids: mediaIDs)
        body.link_url = link?.url
        body.link_title = link?.title
        body.link_description = link?.description
        body.link_domain = link?.domain
        body.link_thumbnail = link?.thumbnailURL
        body.location_name = locationName
        return try await APIClient.shared.request("/records", method: "POST", body: body)
    }

    struct UpdateBody: Encodable {
        let content: String
        let tags: [String]
        let media_ids: [UInt64]
    }

    func update(id: UInt64, content: String, tags: [String], mediaIDs: [UInt64]) async throws -> Record {
        try await APIClient.shared.request("/records/\(id)", method: "PUT", body: UpdateBody(content: content, tags: tags, media_ids: mediaIDs))
    }

    func delete(id: UInt64) async throws {
        let _: APIResponse<Empty> = try await APIClient.shared.request("/records/\(id)", method: "DELETE")
    }

    func search(q: String, tag: String? = nil, type: String? = nil, page: Int = 1) async throws -> ([Record], Int64) {
        var query = [URLQueryItem(name: "q", value: q), URLQueryItem(name: "page", value: "\(page)")]
        if let tag { query.append(URLQueryItem(name: "tag", value: tag)) }
        if let type { query.append(URLQueryItem(name: "type", value: type)) }
        let resp: PaginatedData<Record> = try await APIClient.shared.request("/search", queryItems: query)
        return (resp.items, resp.total)
    }
}

struct Empty: Codable {}
