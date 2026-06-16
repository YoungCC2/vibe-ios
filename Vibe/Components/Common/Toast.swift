//
//  Toast.swift
//  Vibe
//
//  轻量错误提示 Toast — 各页面统一使用
//

import SwiftUI

struct ToastConfig: Equatable {
    var message: String
    var isError: Bool = true
}

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastConfig?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast {
                Text(toast.message)
                    .font(.vibeCaption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(toast.isError ? Color.red.opacity(0.85) : Color.vibeIndigo.opacity(0.85))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(2.5))
                            self.toast = nil
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toast)
    }
}

extension View {
    func toast(_ toast: Binding<ToastConfig?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}
