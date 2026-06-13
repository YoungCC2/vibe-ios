//
//  QuickPostMenu.swift
//  Vibe
//
//  快速发布菜单 — 底部上划面板，基于设计稿 04.md
//

import SwiftUI

struct QuickPostMenu: View {
    @Binding var isPresented: Bool
    @Binding var selectedType: RecordType?

    var body: some View {
        ZStack(alignment: .bottom) {
            // 遮罩层
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { dismiss() }
            }

            // 弹出面板
            if isPresented {
                VStack(spacing: 0) {
                    // 拖拽指示器
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 6)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                    Text("发布新内容")
                        .font(.vibeSubtitle)
                        .foregroundColor(.white)
                        .padding(.bottom, 28)

                    // 2×2 网格
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        postOption(.text, label: "发布文字", icon: "text.bubble.fill", color: .vibeIndigo)
                        postOption(.image, label: "发布图片", icon: "photo.fill", color: Color(hex: "f43f5e"))
                        postOption(.video, label: "发布视频", icon: "play.rectangle.fill", color: Color(hex: "f59e0b"))
                        postOption(.audio, label: "发布音频", icon: "waveform", color: .vibeCyan)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(Color.vibeCardBg)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.vibeCardBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isPresented)
    }

    private func dismiss() {
        isPresented = false
    }

    private func postOption(_ type: RecordType, label: String, icon: String, color: Color) -> some View {
        Button {
            selectedType = type
            dismiss()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: color.opacity(0.4), radius: 6, y: 3)

                Text(label)
                    .font(.vibeBodySmall)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
