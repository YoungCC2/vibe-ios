//
//  Record.swift
//  Vibe
//

import Foundation

enum RecordType: String, Codable, CaseIterable {
    case text, image, video, audio, link

    var label: String {
        switch self {
        case .text:  return "文字"
        case .image: return "图片"
        case .video: return "视频"
        case .audio: return "音频"
        case .link:  return "链接"
        }
    }

    var icon: String {
        switch self {
        case .text:  return "text.bubble.fill"
        case .image: return "photo.fill"
        case .video: return "play.rectangle.fill"
        case .audio: return "waveform"
        case .link:  return "link"
        }
    }
}

struct MediaItem: Codable, Identifiable, Hashable {
    let id: UInt64
    let type: String
    let url: String
    var thumbnailURL: String?
    var width: Int?
    var height: Int?
    let fileSize: Int64
    var duration: Int?

    enum CodingKeys: String, CodingKey {
        case id, type, url, width, height, duration
        case thumbnailURL = "thumbnail_url"
        case fileSize = "file_size"
    }

    // 空字符串 thumbnail 不可用，需要 fallback
    var displayURL: URL? {
        let thumb = (thumbnailURL ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !thumb.isEmpty {
            return absoluteURL(thumb)
        }
        // 没有缩略图，直接用原图
        return absoluteURL(url)
    }

    /// 如果 URL 是相对路径，自动拼接 API 服务器的 host
    private func absoluteURL(_ path: String) -> URL? {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        // 相对路径 → 补全 host
        let base = AppConfig.apiBaseURL                    // http://192.168.50.113:8080/api
        let origin = base.split(separator: "/").prefix(3).joined(separator: "/")  // http://192.168.50.113:8080
        let separator = path.hasPrefix("/") ? "" : "/"
        return URL(string: origin + separator + path)
    }
}

struct LinkInfo: Codable, Hashable {
    var url: String?
    var title: String?
    var description: String?
    var thumbnailURL: String?
    var domain: String?
}

struct Record: Codable, Identifiable, Hashable {
    let id: UInt64
    let type: RecordType
    var content: String
    var tags: [String]
    var media: [MediaItem]
    var link: LinkInfo?
    var locationName: String?
    let createdAt: String
    let updatedAt: String

    // 解析后的日期
    var createdDate: Date? {
        createdAt.vibeISO8601
    }

    var formattedDate: String {
        createdDate?.vibeFormatted() ?? createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, type, content, tags, media
        case linkURL = "link_url"
        case linkTitle = "link_title"
        case linkDescription = "link_description"
        case linkThumbnail = "link_thumbnail"
        case linkDomain = "link_domain"
        case locationName = "location_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(id: UInt64, type: RecordType, content: String, tags: [String], media: [MediaItem], link: LinkInfo?, locationName: String? = nil, createdAt: String, updatedAt: String) {
        self.id = id
        self.type = type
        self.content = content
        self.tags = tags
        self.media = media
        self.link = link
        self.locationName = locationName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UInt64.self, forKey: .id)
        type = try c.decode(RecordType.self, forKey: .type)
        content = try c.decodeIfPresent(String.self, forKey: .content) ?? ""
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        media = try c.decodeIfPresent([MediaItem].self, forKey: .media) ?? []
        createdAt = try c.decode(String.self, forKey: .createdAt)
        updatedAt = try c.decode(String.self, forKey: .updatedAt)
        locationName = try c.decodeIfPresent(String.self, forKey: .locationName)

        let url = try c.decodeIfPresent(String.self, forKey: .linkURL)
        if url != nil {
            link = LinkInfo(
                url: url,
                title: try c.decodeIfPresent(String.self, forKey: .linkTitle),
                description: try c.decodeIfPresent(String.self, forKey: .linkDescription),
                thumbnailURL: try c.decodeIfPresent(String.self, forKey: .linkThumbnail),
                domain: try c.decodeIfPresent(String.self, forKey: .linkDomain)
            )
        } else {
            link = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(type, forKey: .type)
        try c.encode(content, forKey: .content)
        try c.encode(tags, forKey: .tags)
        try c.encode(media, forKey: .media)
        try c.encodeIfPresent(link?.url, forKey: .linkURL)
        try c.encodeIfPresent(link?.title, forKey: .linkTitle)
        try c.encodeIfPresent(link?.description, forKey: .linkDescription)
        try c.encodeIfPresent(link?.thumbnailURL, forKey: .linkThumbnail)
        try c.encodeIfPresent(link?.domain, forKey: .linkDomain)
        try c.encodeIfPresent(locationName, forKey: .locationName)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
    }
}
