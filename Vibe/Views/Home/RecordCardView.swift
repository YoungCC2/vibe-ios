//
//  RecordCardView.swift
//  Vibe
//
//  时间线记录卡片 — 私人日记版，保留设计稿视觉风格
//

import SwiftUI
import AVKit

struct RecordCardView: View {
    let record: Record

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 卡片头部：类型标签 + 时间
            HStack {
                typeBadge
                Spacer()
                Text(record.formattedDate)
                    .font(.vibeCaptionTiny)
                    .foregroundColor(.vibeTextTertiary)
            }

            // 文字内容
            if !record.content.isEmpty {
                Text(record.content)
                    .font(.vibeBody)
                    .foregroundColor(.vibeTextPrimary)
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // 媒体内容（4:5 比例大图）
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
                            .font(.vibeCaption)
                            .foregroundColor(Color.tagColor(for: idx))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.vibeTagBg)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 32)
    }

    // 类型标签胶囊
    private var typeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: record.type.icon)
                .font(.system(size: 11))
            Text(record.type.label.uppercased())
                .font(.vibeCaptionTiny)
                .tracking(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.vibeNavBg)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var mediaContent: some View {
        switch record.type {
        case .image:
            if record.media.count == 1 {
                // 单图：4:5 大图
                SingleImageView(media: record.media[0])
            } else {
                // 多图：网格
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

// MARK: - 单图（4:5 比例）
struct SingleImageView: View {
    let media: MediaItem
    @State private var showFullscreen = false

    var body: some View {
        AsyncImage(url: URL(string: media.thumbnailURL ?? media.url)) { phase in
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
        .frame(maxWidth: .infinity)
        .aspectRatio(4.0/5.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
        .onTapGesture { showFullscreen = true }
        .fullScreenCover(isPresented: $showFullscreen) {
            FullscreenImageViewer(
                media: [media],
                startIndex: 0
            )
        }
    }
}

// MARK: - 多图画廊（2列网格）
struct ImageGalleryView: View {
    let media: [MediaItem]
    @State private var selectedIndex: Int?

    var body: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(media.enumerated()), id: \.element.id) { idx, m in
                AsyncImage(url: URL(string: m.thumbnailURL ?? m.url)) { image in
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
                        .font(.vibeBody)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
            }
            .padding(24)
        }
        .onAppear { currentIndex = startIndex }
    }
}

// MARK: - 视频缩略图（4:5 + 毛玻璃播放键）
struct VideoThumbnailView: View {
    let media: MediaItem
    @State private var showPlayer = false

    var body: some View {
        ZStack {
            // 4:5 比例封面
            AsyncImage(url: URL(string: media.thumbnailURL ?? media.url)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Color.vibeInputBg
                default:
                    Color.vibeInputBg.overlay(ProgressView().tint(.white))
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(4.0/5.0, contentMode: .fit)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)

            // 渐变遮罩（底部加深）
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.black.opacity(0.4), .clear, .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .aspectRatio(4.0/5.0, contentMode: .fit)

            // 毛玻璃播放按钮（设计稿风格）
            Image(systemName: "play.fill")
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.white.opacity(0.3))
                .background(.ultraThinMaterial)
                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
                .offset(x: 2) // play 图标视觉居中偏移
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

    var body: some View {
        HStack(spacing: 14) {
            // 播放/暂停按钮
            Button {
                togglePlay()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .buttonStyle(ScaleButtonStyle())

            // 进度信息
            VStack(alignment: .leading, spacing: 6) {
                // 进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // 轨道
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 4)

                        // 已播放
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.6))
                            .frame(width: duration > 0 ? geo.size.width * CGFloat(currentTime / duration) : 0, height: 4)
                    }
                }
                .frame(height: 4)

                // 时间
                HStack {
                    Text(formatTime(currentTime))
                        .font(.vibeCaptionTiny)
                        .foregroundColor(.vibeTextTertiary)
                    Spacer()
                    Text(formatTime(duration))
                        .font(.vibeCaptionTiny)
                        .foregroundColor(.vibeTextTertiary)
                }
            }
        }
        .padding(16)
        .background(Color.vibeInputBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onDisappear {
            cleanup()
        }
    }

    private func togglePlay() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
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
        duration = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)

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
            // 缩略图
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

            // 文字
            VStack(alignment: .leading, spacing: 4) {
                Text(link.title ?? "链接")
                    .font(.vibeBody)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(link.domain ?? "")
                    .font(.vibeCaption)
                    .foregroundColor(.vibeTextTertiary)

                if let desc = link.description {
                    Text(desc)
                        .font(.vibeCaption)
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
