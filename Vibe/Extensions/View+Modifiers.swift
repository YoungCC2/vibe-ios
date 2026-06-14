//
//  View+Modifiers.swift
//  Vibe
//

import SwiftUI

// 毛玻璃卡片修饰器
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 32

    func body(content: Content) -> some View {
        content
            .background(Color.vibeCardBg)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.vibeCardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color(hex: "1f2687").opacity(0.2), radius: 8, y: 4)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 32) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    /// 收起键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// 按钮弹性缩放
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// 渐变背景容器
struct VibeBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.vibeIndigo, .vibePurple, .vibeCyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 装饰模糊圆形
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 256, height: 256)
                .blur(radius: 40)
                .offset(x: 140, y: -280)

            Circle()
                .fill(Color.vibeIndigo.opacity(0.1))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -140, y: 300)
        }
    }
}
