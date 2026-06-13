//
//  HomeView.swift
//  Vibe
//
//  首页时间线 — 基于设计稿 01
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var showQuickMenu = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 时间线列表
            ScrollView {
                LazyVStack(spacing: 16) {
                    if vm.records.isEmpty && !vm.isLoading {
                        EmptyStateView()
                            .padding(.top, 80)
                    }

                    ForEach(vm.records) { record in
                        RecordCardView(record: record)
                            .onAppear {
                                if record.id == vm.records.last?.id {
                                    Task { await vm.loadMore() }
                                }
                            }
                    }

                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 24)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 120) // 给底部导航 + FAB 留空间
            }
            .refreshable {
                await vm.refresh()
            }

            // 浮动发布按钮
            FloatingPostButton()
                .padding(.trailing, 24)
                .padding(.bottom, 100)
        }
        .task {
            if vm.records.isEmpty { await vm.load() }
        }
        .sheet(isPresented: $showQuickMenu) {
            QuickPostMenu()
                .presentationDetents([.height(280)])
                .presentationBackground(.clear)
        }
    }
}

// 空状态
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(.vibeTextPlaceholder)

            Text("还没有记录")
                .font(.vibeBody)
                .foregroundColor(.vibeTextSecondary)

            Text("点击右下角 + 发布第一条吧")
                .font(.vibeCaption)
                .foregroundColor(.vibeTextTertiary)
        }
    }
}
