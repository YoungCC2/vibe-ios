//
//  APIResponse.swift
//  Vibe
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}

struct PaginatedData<T: Codable>: Codable {
    let items: [T]
    let total: Int64
    let page: Int
    let pageSize: Int

    enum CodingKeys: String, CodingKey {
        case items, total, page
        case pageSize = "page_size"
    }
}

struct LoginResponse: Codable {
    let token: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case token
        case expiresAt = "expires_at"
    }
}

struct UploadResult: Codable {
    let mediaID: UInt64
    let type: String
    let url: String
    var thumbnailURL: String?
    var width: Int?
    var height: Int?
    let fileSize: Int64
    let mimeType: String

    enum CodingKeys: String, CodingKey {
        case mediaID = "media_id"
        case type, url
        case thumbnailURL = "thumbnail_url"
        case width, height
        case fileSize = "file_size"
        case mimeType = "mime_type"
    }
}

struct LinkPreviewResult: Codable {
    let url: String
    let title: String?
    let description: String?
    var thumbnailURL: String?
    var domain: String?

    enum CodingKeys: String, CodingKey {
        case url, title, description, domain
        case thumbnailURL = "thumbnail_url"
    }
}

struct StatsResponse: Codable {
    let totalRecords: Int64
    let recordsByType: [String: Int64]
    let totalTags: Int64
    let storageUsed: StorageUsed

    enum CodingKeys: String, CodingKey {
        case totalRecords = "total_records"
        case recordsByType = "records_by_type"
        case totalTags = "total_tags"
        case storageUsed = "storage_used"
    }
}

struct StorageUsed: Codable {
    let mediaBytes: Int64
    let mediaHuman: String

    enum CodingKeys: String, CodingKey {
        case mediaBytes = "media_bytes"
        case mediaHuman = "media_human"
    }
}
