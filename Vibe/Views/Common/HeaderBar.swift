//
//  HeaderBar.swift
//  Vibe
//
//  统一顶部导航栏 — 基于设计稿 002.md (HeaderBar 组件)
//

import SwiftUI

struct HeaderBar: View {
    var showActions: Bool = true
    var onSearch: (() -> Void)? = nil

    var body: some View {
        HStack {
            // Logo 区
            HStack(spacing: 8) {
                // 白色圆角方块 + 闪电图标，带 -3° 旋转
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 22))
                            .foregroundColor(.vibeIndigo)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .rotationEffect(.degrees(-3))

                Text("Vibe")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .italic()
                    .foregroundColor(.white)
            }

            Spacer()

            if showActions {
                HStack(spacing: 12) {
                    if let onSearch {
                        Button {
                            onSearch()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.vibeNavBg)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
