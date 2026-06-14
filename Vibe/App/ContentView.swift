//
//  ContentView.swift
//  Vibe
//
//  根视图 — 底部 3 Tab + HeaderBar + 浮动发布键 + QuickPostMenu
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showSearch = false
    @State private var showQuickMenu = false
    @State private var quickMenuType: RecordType?
    @State private var showCreate = false
    @State private var createRefreshTrigger = 0
    let authService: AuthService

    enum Tab: String, CaseIterable {
        case home = "首页"
        case discover = "发现"
        case profile = "个人"
    }

    var body: some View {
        ZStack {
            VibeBackground()

            VStack(spacing: 0) {
                // 顶部 HeaderBar
                HeaderBar {
                    showSearch = true
                }

                // 页面内容
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(refreshTrigger: createRefreshTrigger)
                        case .discover:
                            NavigationStack { DiscoverView() }
                        case .profile:
                            ScrollView {
                                ProfileView(authService: authService)
                            }
                        }
                    }

                    // 浮动发布按钮（设计稿：白色圆形 + 加号）
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            showQuickMenu = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.vibeIndigo)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.trailing, 24)
                    .padding(.bottom, 100)
                }

                // 底部导航栏（毛玻璃圆角）
                HStack {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: iconFor(tab))
                                    .font(.system(size: 22))
                                Text(tab.rawValue)
                                    .font(.vibeCaptionTiny)
                            }
                            .foregroundColor(selectedTab == tab ? .white : .vibeTextTertiary)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .padding(.top, 12)
                .background(Color.vibeNavBg)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.vibeCardBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.3), radius: 16, y: -4)
            }
        }
        // QuickPostMenu 遮罩层
        .overlay {
            QuickPostMenu(isPresented: $showQuickMenu, selectedType: $quickMenuType)
        }
        .onChange(of: quickMenuType) { _, type in
            if type != nil {
                showQuickMenu = false
                showCreate = true
            }
        }
        .sheet(isPresented: $showCreate, onDismiss: {
            createRefreshTrigger += 1
            quickMenuType = nil
        }) {
            CreateRecordView(initialType: quickMenuType ?? .text)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
                .presentationDragIndicator(.visible)
        }
    }

    private func iconFor(_ tab: Tab) -> String {
        switch tab {
        case .home:
            return selectedTab == .home ? "house.fill" : "house"
        case .discover:
            return selectedTab == .discover ? "safari.fill" : "safari"
        case .profile:
            return selectedTab == .profile ? "person.fill" : "person"
        }
    }
}
