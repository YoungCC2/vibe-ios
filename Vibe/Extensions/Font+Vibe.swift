//
//  Font+Vibe.swift
//  Vibe
//
//  Plus Jakarta Sans 字体规范
//

import SwiftUI

extension Font {
    // 标题
    static let vibeTitleLarge = Font.custom("PlusJakartaSans-ExtraBold", size: 34)
    static let vibeTitle      = Font.custom("PlusJakartaSans-ExtraBold", size: 28)

    // 小标题
    static let vibeSubtitle   = Font.custom("PlusJakartaSans-Bold", size: 18)

    // 正文
    static let vibeBody       = Font.custom("PlusJakartaSans-SemiBold", size: 16)
    static let vibeBodySmall  = Font.custom("PlusJakartaSans-Medium", size: 14)

    // 辅助
    static let vibeCaption    = Font.custom("PlusJakartaSans-SemiBold", size: 12)
    static let vibeCaptionTiny = Font.custom("PlusJakartaSans-SemiBold", size: 10)

    // 输入框
    static let vibeInput      = Font.custom("PlusJakartaSans-Bold", size: 18)
}
