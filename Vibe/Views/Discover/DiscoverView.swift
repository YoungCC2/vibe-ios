//
//  DiscoverView.swift
//  Vibe
//
//  发现页 — 标签浏览 + 时间浏览
//

import SwiftUI

struct DiscoverView: View {
    @State private var tags: [Tag] = []
    @State private var isLoading = false

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
                                // TODO: TagRecordsView
                                Text(tag.name)
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
                            // TODO: MonthRecordsView
                            Text(month)
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
        .task {
            await loadTags()
        }
    }

    private func loadTags() async {
        isLoading = true
        do {
            tags = try await TagService.shared.list()
        } catch {
            print("标签加载失败: \(error)")
        }
        isLoading = false
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
