//
//  Color+Vibe.swift
//  Vibe
//
//  Vibe 设计规范配色 — 基于 design02.md
//

import SwiftUI

extension Color {
    // MARK: - 主渐变三色（紫-粉-青）
    static let vibeIndigo = Color(hex: "6366f1")
    static let vibePurple = Color(hex: "a855f7")
    static let vibeCyan   = Color(hex: "06b6d4")

    // 主渐变
    static var vibeMainGradient: LinearGradient {
        LinearGradient(
            colors: [.vibeIndigo, .vibePurple, .vibeCyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // 登录按钮渐变
    static var vibeButtonGradient: LinearGradient {
        LinearGradient(
            colors: [.vibeIndigo, .vibePurple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - 毛玻璃
    static let vibeCardBg       = Color.white.opacity(0.15)
    static let vibeCardBorder   = Color.white.opacity(0.2)
    static let vibeInputBg      = Color.white.opacity(0.1)
    static let vibeInputBgFocus = Color.white.opacity(0.2)
    static let vibeNavBg        = Color.white.opacity(0.2)

    // MARK: - 文字
    static let vibeTextPrimary   = Color.white
    static let vibeTextSecondary = Color.white.opacity(0.7)
    static let vibeTextTertiary  = Color.white.opacity(0.5)
    static let vibeTextPlaceholder = Color.white.opacity(0.3)

    // MARK: - 标签
    static let vibeTagBg = Color.white.opacity(0.1)

    // MARK: - AI 评价强调色
    static let vibeAccent = Color(hex: "a78bfa")  // 淡紫色，跟主渐变协调
    static let vibeTagColors: [Color] = [
        Color(hex: "6366f1"),
        Color(hex: "a855f7"),
        Color(hex: "06b6d4"),
        Color(hex: "f59e0b"),
        Color(hex: "10b981"),
        Color(hex: "f43f5e"),
    ]

    static func tagColor(for index: Int) -> Color {
        vibeTagColors[index % vibeTagColors.count]
    }
}

// MARK: - Hex 初始化
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
