//
//  Date+Format.swift
//  Vibe
//

import Foundation

extension Date {
    func vibeFormatted() -> String {
        let now = Date()
        let cal = Calendar.current

        if cal.isDateInToday(self) {
            return "今天 " + Self.timeFormatter.string(from: self)
        }
        if cal.isDateInYesterday(self) {
            return "昨天 " + Self.timeFormatter.string(from: self)
        }

        let days = cal.dateComponents([.day], from: self, to: now).day ?? 0
        if days < 7 {
            return "\(days)天前"
        }

        return Self.dateFormatter.string(from: self)
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM月dd日 HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
}

extension String {
    var vibeISO8601: Date? {
        // 尝试带小数秒+时区的 ISO8601
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f1.date(from: self) { return d }
        // 尝试标准 ISO8601
        if let d = ISO8601DateFormatter().date(from: self) { return d }
        // 尝试无时区的格式（后端可能返回 "2026-06-16T20:00:00"）
        let f2 = DateFormatter()
        f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f2.locale = Locale(identifier: "en_US_POSIX")
        f2.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return f2.date(from: self)
    }
}
