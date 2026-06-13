//
//  Tag.swift
//  Vibe
//

import Foundation

struct Tag: Codable, Identifiable, Hashable {
    let id: UInt64
    let name: String
    var color: String?
    var sortOrder: Int?
    var recordCount: Int64?

    enum CodingKeys: String, CodingKey {
        case id, name, color
        case sortOrder = "sort_order"
        case recordCount = "record_count"
    }
}
