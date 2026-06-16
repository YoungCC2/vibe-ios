//
//  AppConfig.swift
//  Vibe
//

import Foundation

enum AppConfig {
    /// API base URL — 从 Info.plist 读取，方便不同环境切换
    static let apiBaseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "VibeAPIBaseURL") as? String,
              !url.isEmpty else {
            // 兜底默认值（本地开发）
            return "http://localhost:8080/api"
        }
        return url
    }()
}
