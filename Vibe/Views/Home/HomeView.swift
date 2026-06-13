//
//  HomeView.swift
//  Vibe
//
//  首页时间线
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
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
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 140)
        }
        .refreshable {
            await vm.refresh()
        }
        .task {
            if vm.records.isEmpty { await vm.load() }
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
