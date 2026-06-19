//
//  ReviewSection.swift
//  Vibe
//
//  卡片底部的 AI 评价区域
//  单条评价，三种状态：pending / done / failed
//

import SwiftUI

struct ReviewSection: View {
    let recordID: UInt64
    @State private var review: AiReview?
    @State private var isLoading = false
    @State private var hasLoaded = false

    var body: some View {
        Group {
            if let review {
                switch review.status {
                case .pending:
                    ReviewLoadingView(personaName: review.personaName)
                case .done:
                    ReviewBadge(review: review)
                case .failed:
                    ReviewFailedView(personaName: review.personaName) {
                        await retry()
                    }
                }
            } else if isLoading {
                ReviewLoadingView(personaName: nil)
            } else {
                EmptyView()
            }
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await loadReview()
        }
    }

    private func loadReview() async {
        isLoading = true
        do {
            let reviews = try await AiReviewService.shared.getReviews(recordID: recordID)
            review = reviews.first
        } catch {
            // 静默失败，不展示
        }
        isLoading = false
    }

    private func retry() async {
        do {
            try await AiReviewService.shared.retryReviews(recordID: recordID)
            await loadReview()
        } catch {
            // 静默
        }
    }
}

// MARK: - 评价完成展示
struct ReviewBadge: View {
    let review: AiReview

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
                    .foregroundColor(.vibeAccent)
                Text(review.personaName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.vibeAccent)
                Spacer()
                Text("AI 评价")
                    .font(.system(size: 10))
                    .foregroundColor(.vibeTextTertiary)
            }

            Text(review.content)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.85))
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.06), Color.white.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - 加载中状态
struct ReviewLoadingView: View {
    let personaName: String?
    @State private var animate = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundColor(.vibeAccent)

            if let personaName {
                Text("\(personaName) 正在思考...")
                    .font(.system(size: 12))
            } else {
                Text("等待 AI 评价...")
                    .font(.system(size: 12))
            }

            Spacer()

            // 呼吸点
            Circle()
                .fill(Color.vibeAccent.opacity(animate ? 0.3 : 1.0))
                .frame(width: 6, height: 6)
        }
        .foregroundColor(.vibeTextTertiary)
        .padding(14)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                animate.toggle()
            }
        }
    }
}

// MARK: - 失败状态
struct ReviewFailedView: View {
    let personaName: String?
    let onRetry: () async -> Void

    @State private var isRetrying = false

    var body: some View {
        Button {
            Task {
                isRetrying = true
                await onRetry()
                isRetrying = false
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.orange)

                Text("评价失败，点击重试")
                    .font(.system(size: 12))

                Spacer()

                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11))
            }
            .foregroundColor(.vibeTextTertiary)
            .padding(14)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
