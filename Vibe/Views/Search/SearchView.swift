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
    @State private var toast: ToastConfig?
    @State private var currentPage = 1
    @State private var totalResults: Int64 = 0
    @State private var hasMore = false

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
            if isLoading && results.isEmpty {
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
                                .onAppear {
                                    if record.id == results.last?.id && hasMore {
                                        Task { await loadMore() }
                                    }
                                }
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .padding(20)
        .toast($toast)
    }

    private func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        currentPage = 1
        do {
            let (items, total) = try await RecordService.shared.search(q: query, page: currentPage)
            results = items
            totalResults = total
            hasMore = items.count >= 20
        } catch {
            toast = ToastConfig(message: error.localizedDescription)
        }
        hasSearched = true
        isLoading = false
    }

    private func loadMore() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        currentPage += 1
        do {
            let (items, _) = try await RecordService.shared.search(q: query, page: currentPage)
            results.append(contentsOf: items)
            hasMore = items.count >= 20
        } catch {
            currentPage -= 1
            hasMore = false
        }
        isLoading = false
    }
}
