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
    @Published var errorMessage: String?

    private var page = 1
    private let pageSize = 20

    func load() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let (items, _) = try await RecordService.shared.list(page: 1, pageSize: pageSize)
            records = items
            hasMore = items.count == pageSize
        } catch {
            errorMessage = error.localizedDescription
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
            errorMessage = error.localizedDescription
            page -= 1
        }

        isLoading = false
    }
}
