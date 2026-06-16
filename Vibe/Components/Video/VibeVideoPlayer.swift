//
//  VibeVideoPlayer.swift
//  Vibe
//
//  统一视频播放组件 — 直接基于 AVKit
//  外部只需调用 VibeVideoPlayer，不需要关心底层实现
//

import SwiftUI
import AVKit

/// Vibe 统一视频播放器
/// 用法：
///   VibeVideoPlayer(url: videoURL, config: .feed)
///   VibeVideoPlayer(url: videoURL, config: .fullscreen)
struct VibeVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    var config: VideoPlayerConfig = .feed

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)

        // 应用配置
        player.isMuted = config.muted

        controller.player = player
        controller.showsPlaybackControls = config.showsControls
        controller.modalPresentationStyle = .fullScreen

        // 循环播放：监听播放结束 → seek 回开头
        if config.loopPlayback {
            context.coordinator.loopPlayer = player
            context.coordinator.observer = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        if config.autoPlay {
            player.play()
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        if let observer = coordinator.observer {
            NotificationCenter.default.removeObserver(observer)
        }
        coordinator.loopPlayer?.pause()
        coordinator.loopPlayer = nil
    }

    final class Coordinator {
        weak var loopPlayer: AVPlayer?
        var observer: NSObjectProtocol?
    }
}
