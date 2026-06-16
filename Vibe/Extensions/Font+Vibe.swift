//
//  Font+Vibe.swift
//  Vibe
//
//  字体规范 — 使用系统字体 + 相近权重
//  如果后续要嵌入 PlusJakartaSans，改回 custom 即可
//

import SwiftUI

extension Font {
    // 标题
    static let vibeTitleLarge = Font.system(size: 34, weight: .heavy, design: .rounded)
    static let vibeTitle      = Font.system(size: 28, weight: .heavy, design: .rounded)

    // 小标题
    static let vibeSubtitle   = Font.system(size: 18, weight: .bold, design: .rounded)

    // 正文
    static let vibeBody       = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let vibeBodySmall  = Font.system(size: 14, weight: .medium, design: .rounded)

    // 辅助
    static let vibeCaption    = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let vibeCaptionTiny = Font.system(size: 10, weight: .semibold, design: .rounded)

    // 输入框
    static let vibeInput      = Font.system(size: 18, weight: .bold, design: .rounded)
}
