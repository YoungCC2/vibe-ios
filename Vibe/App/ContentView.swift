//
//  ContentView.swift
//  Vibe
//
//  根视图 — 底部 3 Tab + 搜索
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showSearch = false
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
                // 顶部搜索栏
                HStack {
                    Text("Vibe")
                        .font(.vibeTitle)
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        showSearch.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.vibeNavBg)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // 页面内容
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .discover:
                        NavigationStack { DiscoverView() }
                    case .profile:
                        ScrollView {
                            ProfileView(authService: authService)
                        }
                    }
                }

                // 底部导航栏
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
        .sheet(isPresented: $showSearch) {
            SearchView()
                .presentationDragIndicator(.visible)
        }
    }

    private func iconFor(_ tab: Tab) -> String {
        switch tab {
        case .home:     return "house.fill"
        case .discover: return "compass"
        case .profile:  return "person.fill"
        }
    }
}
