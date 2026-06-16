//
//  DiscoverView.swift
//  Vibe
//
//  发现页 — 标签浏览 + 时间浏览
//

import SwiftUI

struct DiscoverView: View {
    @State private var tags: [Tag] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 标签区
                VStack(alignment: .leading, spacing: 12) {
                    Text("常用标签")
                        .font(.vibeSubtitle)
                        .foregroundColor(.white)

                    FlowLayout(spacing: 10) {
                        ForEach(tags) { tag in
                            NavigationLink {
                                TagRecordsView(tag: tag)
                            } label: {
                                VStack(spacing: 4) {
                                    Text("#\(tag.name)")
                                        .font(.vibeBody)
                                        .foregroundColor(.white)
                                    if let count = tag.recordCount {
                                        Text("\(count)条")
                                            .font(.vibeCaptionTiny)
                                            .foregroundColor(.vibeTextTertiary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.vibeCardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }

                Divider().overlay(Color.vibeCardBorder)

                // 时间浏览
                VStack(alignment: .leading, spacing: 12) {
                    Text("按时间")
                        .font(.vibeSubtitle)
                        .foregroundColor(.white)

                    ForEach(recentMonths(), id: \.self) { month in
                        NavigationLink {
                            MonthRecordsView(monthTitle: month)
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.vibeTextTertiary)
                                Text(month)
                                    .font(.vibeBody)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.vibeTextTertiary)
                            }
                            .padding(16)
                            .background(Color.vibeCardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 120)
        }
        .background(VibeBackground())
        .task {
            await loadTags()
        }
    }

    private func loadTags() async {
        do {
            tags = try await TagService.shared.list()
        } catch {
            print("标签加载失败: \(error)")
        }
    }

    private func recentMonths() -> [String] {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "zh_CN")

        let now = Date()
        return (0..<6).map { i in
            let date = cal.date(byAdding: .month, value: -i, to: now)!
            return formatter.string(from: date)
        }
    }
}

// MARK: - 标签详情页

struct TagRecordsView: View {
    let tag: Tag
    @State private var records: [Record] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                if isLoading && records.isEmpty {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 60)
                }

                if records.isEmpty && !isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "tag")
                            .font(.system(size: 40))
                            .foregroundColor(.vibeTextPlaceholder)
                        Text("暂无记录")
                            .font(.vibeBody)
                            .foregroundColor(.vibeTextSecondary)
                    }
                    .padding(.top, 80)
                }

                ForEach(records) { record in
                    RecordCardView(record: record)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .background(VibeBackground())
        .navigationTitle("#\(tag.name)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRecords()
        }
    }

    private func loadRecords() async {
        isLoading = true
        do {
            let (items, _) = try await RecordService.shared.list(page: 1, pageSize: 50, tag: tag.name)
            records = items
        } catch {
            print("加载失败: \(error)")
        }
        isLoading = false
    }
}

// MARK: - 月份详情页

struct MonthRecordsView: View {
    let monthTitle: String
    @State private var records: [Record] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                if isLoading && records.isEmpty {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 60)
                }

                if records.isEmpty && !isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.vibeTextPlaceholder)
                        Text("该月暂无记录")
                            .font(.vibeBody)
                            .foregroundColor(.vibeTextSecondary)
                    }
                    .padding(.top, 80)
                }

                ForEach(records) { record in
                    RecordCardView(record: record)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .background(VibeBackground())
        .navigationTitle(monthTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRecords()
        }
    }

    private func loadRecords() async {
        isLoading = true
        do {
            // 用搜索的方式查月份记录（按月份标题搜索不够精确）
            // 理想情况下后端应有按日期范围筛选的 API
            let allRecords = try await RecordService.shared.list(page: 1, pageSize: 100)
            // 客户端按月份过滤
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "zh_CN")
            dateFormatter.dateFormat = "yyyy年M月"
            guard let targetDate = dateFormatter.date(from: monthTitle) else {
                records = allRecords.0
                isLoading = false
                return
            }
            let cal = Calendar.current
            records = allRecords.0.filter { record in
                guard let date = record.createdDate else { return false }
                return cal.isDate(date, equalTo: targetDate, toGranularity: .month)
            }
        } catch {
            print("加载失败: \(error)")
        }
        isLoading = false
    }
}
