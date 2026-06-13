//
//  AppConfig.swift
//  Vibe
//

import Foundation

enum AppConfig {
    /// API base URL — 本地开发用 localhost，真机调试换成实际 IP
    static let apiBaseURL = "http://127.0.0.1:8080/api"

    /// 登录 PIN 码（开发用，正式版应从服务端验证）
    static let devAccessCode = "vibe123"
}
