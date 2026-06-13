//
//  ProfileView.swift
//  Vibe
//
//  个人页 — 基于设计稿 04（去掉社交元素）
//

import SwiftUI

struct ProfileView: View {
    @State private var stats: StatsResponse?
    @State private var nickname = "D先生"

    let authService: AuthService

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 个人信息卡片
                VStack(spacing: 12) {
                    // 头像
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.vibeButtonGradient)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        )

                    Text(nickname)
                        .font(.vibeTitle)
                        .foregroundColor(.white)

                    if let stats {
                        Text("已记录 \(stats.totalRecords) 条")
                            .font(.vibeBodySmall)
                            .foregroundColor(.vibeTextSecondary)
                    }
                }
                .padding(24)
                .glassCard()

                // 统计区
                if let stats {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("记录统计")
                            .font(.vibeSubtitle)
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            statItem("文字", count: stats.recordsByType["text"] ?? 0, icon: "text.bubble.fill")
                            statItem("图片", count: stats.recordsByType["image"] ?? 0, icon: "photo.fill")
                        }
                        HStack(spacing: 12) {
                            statItem("视频", count: stats.recordsByType["video"] ?? 0, icon: "play.rectangle.fill")
                            statItem("音频", count: stats.recordsByType["audio"] ?? 0, icon: "waveform")
                        }
                        HStack(spacing: 12) {
                            statItem("链接", count: stats.recordsByType["link"] ?? 0, icon: "link")
                            Spacer()
                        }

                        // 存储
                        if stats.totalRecords > 0 {
                            HStack {
                                Text("存储")
                                    .font(.vibeCaption)
                                    .foregroundColor(.vibeTextTertiary)
                                Spacer()
                                Text(stats.storageUsed.mediaHuman)
                                    .font(.vibeCaption)
                                    .foregroundColor(.vibeTextSecondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(20)
                    .glassCard()
                }

                // 设置
                VStack(spacing: 0) {
                    settingsRow(icon: "arrow.up.doc.fill", label: "导出数据", color: .vibeCyan) {
                        // TODO: 导出
                    }
                    Divider().overlay(Color.vibeCardBorder.opacity(0.5))
                    settingsRow(icon: "info.circle.fill", label: "关于 Vibe", color: .vibePurple) {
                        // TODO: 关于
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassCard()

                // 退出登录
                Button {
                    authService.logout()
                } label: {
                    Text("退出登录")
                        .font(.vibeBody)
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(20)
            .padding(.bottom, 120)
        }
        .task {
            await loadStats()
        }
    }

    private func statItem(_ label: String, count: Int64, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)

            Text("\(count)")
                .font(.vibeTitle)
                .foregroundColor(.white)

            Text(label)
                .font(.vibeCaptionTiny)
                .foregroundColor(.vibeTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.vibeInputBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func settingsRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
                Text(label)
                    .font(.vibeBody)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.vibeTextTertiary)
            }
            .padding(18)
        }
    }

    private func loadStats() async {
        do {
            stats = try await StatsService.shared.get()
        } catch {
            print("统计加载失败: \(error)")
        }
    }
}
