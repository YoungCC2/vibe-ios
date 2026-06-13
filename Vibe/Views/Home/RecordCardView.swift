//
//  RecordCardView.swift
//  Vibe
//
//  内容卡片 — 基于设计稿 ContentCard (00.md / 02.md)
//  私人日记版：去掉社交元素，保留视觉结构
//

import SwiftUI
import AVKit
import Combine

struct RecordCardView: View {
    let record: Record

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 头部：类型标签（右对齐，设计稿位置）
            HStack {
                // 日期/时间（替代设计稿左侧的用户信息）
                Text(record.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.vibeTextSecondary)

                Spacer()

                // 类型标签（设计稿右上角）
                typeBadge
            }

            // 文字内容（设计稿：text-sm text-white/90 font-medium leading-relaxed）
            if !record.content.isEmpty {
                Text(record.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.9))
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }

            // 媒体内容
            if !record.media.isEmpty {
                mediaContent
            }

            // 链接预览
            if record.type == .link, let link = record.link {
                LinkCardView(link: link)
            }

            // 标签
            if !record.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(record.tags.enumerated()), id: \.offset) { idx, tag in
                        Text("#\(tag)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.vibeTagBg)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 32)
    }

    // 类型标签胶囊（设计稿：bg-white/20 rounded-full px-3 py-1）
    private var typeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: record.type.icon)
                .font(.system(size: 11))
            Text(record.type.label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Color.vibeNavBg)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var mediaContent: some View {
        switch record.type {
        case .image:
            if record.media.count == 1 {
                SingleImageView(media: record.media[0])
            } else {
                ImageGalleryView(media: record.media)
            }
        case .video:
            if let first = record.media.first {
                VideoThumbnailView(media: first)
            }
        case .audio:
            ForEach(record.media) { m in
                AudioPlayerBar(media: m)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - 单图（4:5 比例，设计稿 aspect-[4/5] rounded-[24px] shadow-2xl）
struct SingleImageView: View {
    let media: MediaItem
    @State private var showFullscreen = false

    var body: some View {
        // 先用 Rectangle 占位固定 4:5 容器，再 overlay 图片
        Rectangle()
            .fill(Color.vibeInputBg)
            .aspectRatio(4.0/5.0, contentMode: .fit)
            .overlay {
                AsyncImage(url: media.displayURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.vibeInputBg
                            .overlay(Image(systemName: "photo").foregroundColor(.vibeTextTertiary))
                    default:
                        Color.vibeInputBg
                            .overlay(ProgressView().tint(.white))
                    }
                }
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
            .onTapGesture { showFullscreen = true }
            .fullScreenCover(isPresented: $showFullscreen) {
                FullscreenImageViewer(media: [media], startIndex: 0)
            }
    }
}

// MARK: - 多图画廊
struct ImageGalleryView: View {
    let media: [MediaItem]
    @State private var selectedIndex: Int?

    var body: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(media.enumerated()), id: \.element.id) { idx, m in
                AsyncImage(url: m.displayURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.vibeInputBg
                }
                .frame(height: 160)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture { selectedIndex = idx }
            }
        }
        .fullScreenCover(item: Binding(
            get: { selectedIndex.map { IdentifiableInt(value: $0) } },
            set: { selectedIndex = $0?.value }
        )) { idx in
            FullscreenImageViewer(media: media, startIndex: idx.value)
        }
    }
}

struct IdentifiableInt: Identifiable { let value: Int; var id: Int { value } }

// MARK: - 全屏图片浏览器
struct FullscreenImageViewer: View {
    let media: [MediaItem]
    let startIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(media.enumerated()), id: \.element.id) { idx, m in
                    AsyncImage(url: URL(string: m.url)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.black
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

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
                if media.count > 1 {
                    Text("\(currentIndex + 1) / \(media.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
            }
            .padding(24)
        }
        .onAppear { currentIndex = startIndex }
    }
}

// MARK: - 视频缩略图（设计稿：aspect-[4/5] + 渐变遮罩 + 毛玻璃播放键 w-16 h-16）
struct VideoThumbnailView: View {
    let media: MediaItem
    @State private var showPlayer = false

    var body: some View {
        ZStack {
            // 4:5 容器
            Rectangle()
                .fill(Color.vibeInputBg)
                .aspectRatio(4.0/5.0, contentMode: .fit)
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
                .clipShape(RoundedRectangle(cornerRadius: 24))
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
                .aspectRatio(4.0/5.0, contentMode: .fit)
                .allowsHitTesting(false)

            // 毛玻璃播放键（设计稿：w-16 h-16 bg-white/30 backdrop-blur-xl rounded-full border-white/40）
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
        .onTapGesture { showPlayer = true }
        .fullScreenCover(isPresented: $showPlayer) {
            if let url = URL(string: media.url) {
                VideoPlayer(player: AVPlayer(url: url))
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - 音频播放条
struct AudioPlayerBar: View {
    let media: MediaItem
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserver: Any?
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        HStack(spacing: 14) {
            Button {
                togglePlay()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .buttonStyle(ScaleButtonStyle())

            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.6))
                            .frame(width: duration > 0 ? geo.size.width * CGFloat(currentTime / duration) : 0, height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text(formatTime(currentTime))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.vibeTextTertiary)
                    Spacer()
                    Text(formatTime(duration))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.vibeTextTertiary)
                }
            }
        }
        .padding(16)
        .background(Color.vibeInputBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onDisappear { cleanup() }
    }

    private func togglePlay() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            // 配置音频会话为播放模式
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)

            if player == nil, let url = URL(string: media.url) {
                player = AVPlayer(url: url)
                setupObserver()
            }
            player?.play()
            isPlaying = true
        }
    }

    private func setupObserver() {
        guard let player else { return }
        // duration 异步加载，用通知监听
        if let item = player.currentItem {
            // 先尝试直接拿
            let d = CMTimeGetSeconds(item.duration)
            if d > 0 && !d.isNaN {
                duration = d
            }
            // 监听 item 加载完成
            item.publisher(for: \.duration)
                .receive(on: DispatchQueue.main)
                .sink { time in
                    let d = CMTimeGetSeconds(time)
                    if d > 0 && !d.isNaN {
                        self.duration = d
                    }
                }
                .store(in: &cancellables)
        }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
            if currentTime >= duration && duration > 0 {
                isPlaying = false
                currentTime = 0
            }
        }
    }

    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds > 0 else { return "0:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - 链接卡片
struct LinkCardView: View {
    let link: LinkInfo

    var body: some View {
        HStack(spacing: 12) {
            if let thumb = link.thumbnailURL, let url = URL(string: thumb) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.vibeInputBg
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.vibeInputBg)
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "link")
                            .foregroundColor(.vibeTextTertiary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(link.title ?? "链接")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(link.domain ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.vibeTextTertiary)

                if let desc = link.description {
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundColor(.vibeTextSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.vibeInputBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
