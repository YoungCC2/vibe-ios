//
//  JWTDecoder.swift
//  Vibe
//
//  轻量 JWT payload 解析（不需要第三方库）
//

import Foundation

enum JWTDecoder {
    /// 从 JWT token 中解析 payload（不验签，仅读 claims）
    static func payload(from token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }

        var payload = String(parts[1])
        // Base64 URL → Base64
        payload = payload.replacingOccurrences(of: "-", with: "+")
                          .replacingOccurrences(of: "_", with: "/")
        // 补 padding
        let padding = payload.count % 4
        if padding > 0 {
            payload += String(repeating: "=", count: 4 - padding)
        }

        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}
