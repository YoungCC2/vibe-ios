//
//  ProfileView.swift
//  Vibe
//
//  个人页 — 基于设计稿 04-vibe.html（去社交，改日记统计）
//

import SwiftUI

struct ProfileView: View {
    @State private var stats: StatsResponse?
    @State private var recentRecords: [Record] = []
    @State private var toast: ToastConfig?
    @State private var showPersonaList = false
    @State private var showVideoTest = false
    let authService: AuthService

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text("个人中心")
                    .font(.vibeSubtitle)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    // TODO: 设置
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.vibeNavBg)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 24) {
                    // 个人信息卡片（毛玻璃大圆角）
                    VStack(spacing: 16) {
                        // 头像（渐变边框 + 白底）
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "facc15"), Color(hex: "ec4899")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 96, height: 96)
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 88, height: 88)
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.vibeIndigo)
                        }

                        // 名字（从 JWT 解析，兜底 "Vibe 用户"）
                        Text(userName)
                            .font(.vibeTitle)
                            .foregroundColor(.white)

                        Text("记录生活，留住美好")
                            .font(.vibeCaption)
                            .foregroundColor(.vibeTextSecondary)
                            .italic()

                        // 统计数据
                        HStack(spacing: 0) {
                            statBlock(
                                value: "\(stats?.totalRecords ?? 0)",
                                label: "记录"
                            )
                            frameDivider
                            statBlock(
                                value: "\(stats?.recordsByType["image"] ?? 0)",
                                label: "图片"
                            )
                            frameDivider
                            statBlock(
                                value: "\(stats?.recordsByType["video"] ?? 0)",
                                label: "视频"
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .glassCard(cornerRadius: 40)

                    // 我的媒体墙（九宫格）
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("我的回忆")
                                .font(.vibeSubtitle)
                                .foregroundColor(.white)
                            Spacer()
                            // 网格/列表切换（视觉占位）
                            HStack(spacing: 4) {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 14))
                                    .foregroundColor(.vibeTextTertiary)
                            }
                            .padding(6)
                            .background(Color.vibeInputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        if recentRecords.isEmpty {
                            // 占位
                            ForEach(0..<4, id: \.self) { _ in
                                Color.vibeInputBg
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.vibeTextTertiary)
                                    )
                            }
                        } else {
                            let mediaRecords = recentRecords.filter { !$0.media.isEmpty }
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(mediaRecords.prefix(6)) { record in
                                    if let media = record.media.first {
                                        Rectangle()
                                            .fill(Color.vibeInputBg)
                                            .aspectRatio(1, contentMode: .fit)
                                            .overlay {
                                                AsyncImage(url: media.displayURL) { image in
                                                    image.resizable().scaledToFill()
                                                } placeholder: {
                                                    Color.vibeInputBg
                                                }
                                                .clipped()
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(Color.vibeCardBorder, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 8)

                    // 设置列表
                    VStack(alignment: .leading, spacing: 16) {
                        Text("设置")
                            .font(.vibeSubtitle)
                            .foregroundColor(.white)

                        VStack(spacing: 0) {
                            settingsRow(icon: "shield.checkered", label: "账号与安全", color: .vibeIndigo) {}
                            dividerLine
                            settingsRow(icon: "sparkles", label: "AI 评价人设", color: .vibeAccent) {
                                showPersonaList = true
                            }
                            dividerLine
                            settingsRow(icon: "paintpalette.fill", label: "外观与主题", color: .vibePurple) {}
                            dividerLine
                            settingsRow(icon: "globe", label: "语言设置", color: .vibeCyan) {}
                            dividerLine
                            settingsRow(icon: "ladybug.fill", label: "视频调试", color: .orange) {
                                showVideoTest = true
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .glassCard(cornerRadius: 24)

                        // 退出登录
                        Button {
                            authService.logout()
                        } label: {
                            Text("退出登录")
                                .font(.vibeBody)
                                .foregroundColor(Color(hex: "fda4af"))
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
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 140)
            }
        }
        .background(VibeBackground())
        .task {
            await loadData()
        }
        .toast($toast)
        .sheet(isPresented: $showPersonaList) {
            PersonaListView()
        }
        .sheet(isPresented: $showVideoTest) {
            VideoTestView()
        }
    }

    private var userName: String {
        if let token = APIClient.shared.token,
           let payload = JWTDecoder.payload(from: token),
           let name = payload["username"] as? String ?? payload["name"] as? String {
            return name
        }
        return "Vibe 用户"
    }

    // 统计数字块
    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.vibeCaptionTiny)
                .foregroundColor(.vibeTextTertiary)
                .tracking(1)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }

    private var frameDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 32)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
    }

    private func settingsRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 32)
                Text(label)
                    .font(.vibeBody)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.vibeTextTertiary)
            }
            .padding(18)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }

    private func loadData() async {
        do {
            stats = try await StatsService.shared.get()
        } catch {
            toast = ToastConfig(message: "统计加载失败")
        }
        // 加载最近记录用于媒体墙
        do {
            let (records, _) = try await RecordService.shared.list(page: 1, pageSize: 20)
            recentRecords = records
        } catch {
            toast = ToastConfig(message: "记录加载失败")
        }
    }
}
