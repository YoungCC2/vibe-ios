//
//  VibeVideoPlayer.swift
//  Vibe
//
//  统一视频播放组件入口 — 基于当前实现（VideoKit）
//  外部只需调用 VibeVideoPlayer，不需要关心底层用什么库
//  以后换播放器实现时，只改这个文件内部的 body
//

import SwiftUI
import VideoKit

/// Vibe 统一视频播放器
/// 用法：
///   VibeVideoPlayer(url: videoURL, config: .feed)
///   VibeVideoPlayer(media: mediaItem, config: .fullscreen)
struct VibeVideoPlayer: View {
    let url: URL
    var config: VideoPlayerConfig = .feed

    @State private var videoTime: TimeInterval = 0

    var body: some View {
        // === 底层实现：VideoKit ===
        // 以后要换播放器？只改这个 body 里的实现就行
        VideoKitVideoLayer(
            url: url,
            config: config,
            videoTime: $videoTime
        )
        .modifier(VideoContainerModifier(config: config))
    }
}

// MARK: - VideoKit 底层封装（私有）

/// VideoKit 具体实现层 — 外部不应直接使用
private struct VideoKitVideoLayer: View {
    let url: URL
    let config: VideoPlayerConfig
    @Binding var videoTime: TimeInterval

    var body: some View {
        VideoKit.VideoPlayer(
            videoURL: url,
            time: $videoTime,
            configuration: .init(autoPlay: config.autoPlay),
            controllerConfiguration: { controller in
                controller.showsPlaybackControls = config.showsControls
            },
            didPlayToEndAction: {
                // 循环播放：seek 回开头
                if config.loopPlayback {
                    NotificationCenter.default.post(
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: nil
                    )
                }
            }
        )
        .ignoresSafeArea()
    }
}

// MARK: - 容器样式修饰器

/// 统一的容器样式：圆角 + 裁剪 + 阴影
struct VideoContainerModifier: ViewModifier {
    let config: VideoPlayerConfig

    func body(content: Content) -> some View {
        let shaped = Group {
            if let ratio = config.aspectRatio {
                content.aspectRatio(ratio, contentMode: .fit)
            } else {
                content
            }
        }

        return shaped
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
    }
}
