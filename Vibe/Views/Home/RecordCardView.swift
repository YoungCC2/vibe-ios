//
//  RecordCardView.swift
//  Vibe
//
//  时间线记录卡片 — 展示5种内容类型
//

import SwiftUI
import AVKit

struct RecordCardView: View {
    let record: Record

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 文字内容
            if !record.content.isEmpty {
                Text(record.content)
                    .font(.vibeBody)
                    .foregroundColor(.white)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
            }

            // 媒体内容
            if !record.media.isEmpty {
                mediaContent
            }

            // 链接预览
            if let link = record.link, record.type == .link {
                LinkCardView(link: link)
            }

            // 标签 + 时间
            HStack(spacing: 8) {
                ForEach(record.tags.prefix(3), id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.vibeCaption)
                        .foregroundColor(.vibeTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.vibeTagBg)
                        .clipShape(Capsule())
                }

                Spacer()

                Text(record.formattedDate)
                    .font(.vibeCaption)
                    .foregroundColor(.vibeTextTertiary)
            }
        }
        .padding(20)
        .glassCard()
    }

    @ViewBuilder
    private var mediaContent: some View {
        switch record.type {
        case .image:
            if !record.media.isEmpty {
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

// MARK: - 图片画廊
struct ImageGalleryView: View {
    let media: [MediaItem]
    @State private var selectedIndex: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(media.enumerated()), id: \.element.id) { idx, m in
                    AsyncImage(url: URL(string: m.thumbnailURL ?? m.url)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.vibeInputBg
                    }
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture { selectedIndex = idx }
                }
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
                Text("\(currentIndex + 1) / \(media.count)")
                    .font(.vibeBody)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
            }
            .padding(24)
        }
        .onAppear { currentIndex = startIndex }
    }
}

// MARK: - 视频缩略图
struct VideoThumbnailView: View {
    let media: MediaItem
    @State private var showPlayer = false

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: media.thumbnailURL ?? media.url)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.vibeInputBg
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // 播放按钮
            Image(systemName: "play.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.85))
                .shadow(color: .black.opacity(0.4), radius: 8)
        }
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

    var body: some View {
        HStack(spacing: 12) {
            Button {
                togglePlay()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("录音")
                    .font(.vibeCaption)
                    .foregroundColor(.vibeTextSecondary)
                if let duration = media.duration {
                    Text("\(duration / 1000)秒")
                        .font(.vibeCaptionTiny)
                        .foregroundColor(.vibeTextTertiary)
                }
            }

            Spacer()

            Image(systemName: "waveform")
                .foregroundColor(.vibeTextSecondary)
        }
        .padding(16)
        .background(Color.vibeInputBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func togglePlay() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil, let url = URL(string: media.url) {
                player = AVPlayer(url: url)
            }
            player?.play()
            isPlaying = true
        }
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
