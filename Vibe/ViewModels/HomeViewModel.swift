//
//  HomeViewModel.swift
//  Vibe
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var records: [Record] = []
    @Published var isLoading = false
    @Published var hasMore = true

    private var page = 1
    private let pageSize = 20

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        page = 1

        do {
            let (items, _) = try await RecordService.shared.list(page: page, pageSize: pageSize)
            records = items
            hasMore = items.count == pageSize
        } catch {
            print("加载失败: \(error)")
        }

        isLoading = false
    }

    func refresh() async {
        await load()
    }

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        page += 1

        do {
            let (items, _) = try await RecordService.shared.list(page: page, pageSize: pageSize)
            records.append(contentsOf: items)
            hasMore = items.count == pageSize
        } catch {
            page -= 1
        }

        isLoading = false
    }
}
