//
//  LoginView.swift
//  Vibe
//
//  PIN 码登录页 — 基于设计稿 06-login.md
//

import SwiftUI

struct LoginView: View {
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMsg: String?
    @FocusState private var isFocused: Bool

    let authService: AuthService

    var body: some View {
        ZStack {
            VibeBackground()

            VStack(spacing: 0) {
                // Logo 区域
                VStack(spacing: 12) {
                    AppLogo(size: 80)

                    Text("Vibe")
                        .font(.vibeTitleLarge)
                        .foregroundColor(.white)

                    Text("记录你的每个瞬间")
                        .font(.vibeBodySmall)
                        .foregroundColor(.vibeTextSecondary)
                }
                .padding(.top, 60)

                Spacer()

                // 登录表单
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("验证码")
                            .font(.vibeCaption)
                            .foregroundColor(.vibeTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .foregroundColor(.vibeTextTertiary)
                                .font(.system(size: 18))

                            TextField("", text: $code)
                                .font(.vibeInput)
                                .foregroundColor(.white)
                                .textContentType(.oneTimeCode)
                                .multilineTextAlignment(.center)
                                .tracking(8)
                                .placeholder("请输入登录码", when: code.isEmpty, color: .vibeTextPlaceholder)
                                .focused($isFocused)
                        }
                        .frame(height: 56)
                        .background(Color.vibeInputBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? Color.vibeCardBorder : Color.clear, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        Task { await login() }
                    } label: {
                        HStack(spacing: 8) {
                            Text("即刻开启")
                                .font(.vibeBody)
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.vibeButtonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(code.isEmpty || isLoading)

                    if let errorMsg {
                        Text(errorMsg)
                            .font(.vibeCaption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .padding(32)
                .glassCard()

                Spacer()
                Spacer()

                // 底部
                Text("登录即代表同意 用户协议 与 隐私政策")
                    .font(.system(size: 10))
                    .foregroundColor(.vibeTextPlaceholder)
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 24)
        }
        .onAppear { isFocused = true }
    }

    private func login() async {
        isLoading = true
        errorMsg = nil
        do {
            try await authService.login(code: code)
        } catch let APIError.serverError(_, msg) {
            errorMsg = msg
        } catch {
            errorMsg = "网络错误，请重试"
        }
        isLoading = false
    }
}

// Placeholder modifier
extension View {
    func placeholder(_ text: String, when shouldShow: Bool, color: Color) -> some View {
        ZStack(alignment: .center) {
            shouldShow ? Text(text).foregroundColor(color).font(.vibeBody) : nil
            self
        }
    }
}
