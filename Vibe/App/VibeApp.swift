//
//  VibeApp.swift
//  Vibe
//
//  App 入口
//

import SwiftUI

@main
struct VibeApp: App {
    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isLoggedIn {
                    ContentView(authService: authService)
                } else {
                    LoginView(authService: authService)
                }
            }
            .animation(.easeInOut, value: authService.isLoggedIn)
        }
    }
}
