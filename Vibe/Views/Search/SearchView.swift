//
//  SearchView.swift
//  Vibe
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: [Record] = []
    @State private var hasSearched = false
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            // 搜索栏
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.vibeTextTertiary)

                TextField("搜索记录...", text: $query)
                    .font(.vibeBody)
                    .foregroundColor(.white)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await search() }
                    }
            }
            .padding(16)
            .background(Color.vibeInputBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // 结果
            if isLoading {
                Spacer()
                ProgressView().tint(.white)
                Spacer()
            } else if hasSearched && results.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.vibeTextPlaceholder)
                    Text("没有找到相关记录")
                        .font(.vibeBody)
                        .foregroundColor(.vibeTextSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(results) { record in
                            RecordCardView(record: record)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .padding(20)
    }

    private func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        do {
            let (items, _) = try await RecordService.shared.search(q: query)
            results = items
        } catch {
            print("搜索失败: \(error)")
        }
        hasSearched = true
        isLoading = false
    }
}
