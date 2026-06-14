//
//  VideoThumbnailCard.swift
//  Vibe
//
//  视频缩略图卡片 — 信息流中的视频展示
//  点击缩略图 → 全屏播放
//  由 RecordCardView 调用，不关心底层播放器实现
//

import SwiftUI

/// 视频缩略图卡片（信息流用）
/// 显示封面图 + 毛玻璃播放键，点击进入全屏播放
struct VideoThumbnailCard: View {
    let media: MediaItem
    var feedConfig: VideoPlayerConfig = .feed
    var fullscreenConfig: VideoPlayerConfig = .fullscreen

    @State private var showFullscreen = false

    var body: some View {
        ZStack {
            // 4:5 封面容器
            Rectangle()
                .fill(Color.vibeInputBg)
                .aspectRatio(4.0 / 5.0, contentMode: .fit)
                .overlay {
                    AsyncImage(url: media.displayURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Color.vibeInputBg
                        default:
                            Color.vibeInputBg.overlay(ProgressView().tint(.white))
                        }
                    }
                    .clipped()
                }
                .clipShape(RoundedRectangle(cornerRadius: feedConfig.cornerRadius))
                .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                .allowsHitTesting(false)

            // 渐变遮罩
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.black.opacity(0.4), .clear, .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .aspectRatio(4.0 / 5.0, contentMode: .fit)
                .allowsHitTesting(false)

            // 毛玻璃播放键
            Image(systemName: "play.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.white.opacity(0.3))
                .background(.ultraThinMaterial)
                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
                .offset(x: 2)
        }
        .contentShape(Rectangle())
        .onTapGesture { showFullscreen = true }
        .fullScreenCover(isPresented: $showFullscreen) {
            if let url = URL(string: media.url) {
                FullscreenVideoContainer(url: url, config: fullscreenConfig)
            }
        }
    }
}

// MARK: - 全屏播放容器

/// 全屏视频播放容器（封装关闭按钮 + 黑底）
struct FullscreenVideoContainer: View {
    let url: URL
    let config: VideoPlayerConfig
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VibeVideoPlayer(url: url, config: config)

            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding(24)
        }
    }
}
