//
//  QuickPostMenu.swift
//  Vibe
//
//  快速发布菜单 — 底部上划面板
//

import SwiftUI

struct QuickPostMenu: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.vibeIndigo.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // 拖拽指示器
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                Text("发布")
                    .font(.vibeSubtitle)
                    .foregroundColor(.white)

                // 类型选择
                HStack(spacing: 16) {
                    postOption(.text, label: "文字", icon: "text.bubble.fill")
                    postOption(.image, label: "图片", icon: "photo.fill")
                    postOption(.video, label: "视频", icon: "play.rectangle.fill")
                }

                HStack(spacing: 16) {
                    postOption(.audio, label: "音频", icon: "waveform")
                    postOption(.link, label: "链接", icon: "link")
                }

                Spacer()
            }
            .padding(.bottom, 34)
        }
    }

    private func postOption(_ type: RecordType, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.vibeCardBg)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.vibeCardBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(label)
                .font(.vibeCaption)
                .foregroundColor(.vibeTextSecondary)
        }
        .buttonStyle(ScaleButtonStyle())
        .onTapGesture {
            // TODO: 导航到 CreateRecordView
            dismiss()
        }
    }
}

// MARK: - 浮动发布按钮
struct FloatingPostButton: View {
    var body: some View {
        Button {
            // TODO: 触发 QuickPostMenu
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.vibeIndigo)
                .frame(width: 56, height: 56)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
