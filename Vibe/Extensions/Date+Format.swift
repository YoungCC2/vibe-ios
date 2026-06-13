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
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: self) ?? ISO8601DateFormatter().date(from: self)
    }
}
