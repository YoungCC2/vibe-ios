//
//  CreateRecordView.swift
//  Vibe
//
//  创建记录页 — 基于设计稿 01.md
//

import SwiftUI

struct CreateRecordView: View {
    @State private var selectedType: RecordType

    init(initialType: RecordType = .text) {
        _selectedType = State(initialValue: initialType)
    }
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var tagInput = ""
    @State private var linkURL = ""
    @State private var linkPreview: LinkPreviewResult?
    @State private var isLoadingPreview = false
    @State private var isPublishing = false

    @Environment(\.dismiss) var dismiss

    // 设计稿只显示4种类型（无链接）
    private let createTypes: [RecordType] = [.text, .image, .video, .audio]
    private let suggestedTags = ["灵感记录", "每日Vibe"]

    var body: some View {
        ZStack {
            VibeBackground()

            VStack(spacing: 0) {
                // 自定义顶部导航（设计稿：返回键 + 居中标题 + 空占位）
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.vibeNavBg)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Spacer()

                    Text("发布新动态")
                        .font(.vibeSubtitle)
                        .foregroundColor(.white)

                    Spacer()

                    // 空占位（与返回键等宽对齐）
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        // 类型 Tab（设计稿：横向滚动，选中白底indigo文字）
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(createTypes, id: \.self) { type in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedType = type
                                        }
                                    } label: {
                                        Text(type.label)
                                            .font(.vibeBodySmall)
                                            .foregroundColor(selectedType == type ? .vibeIndigo : .white)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(selectedType == type ? Color.white : Color.vibeNavBg)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .shadow(color: selectedType == type ? .white.opacity(0.3) : .clear, radius: 6, y: 3)
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }

                        // 文字输入 + 标签（毛玻璃卡片）
                        VStack(spacing: 16) {
                            // 文字输入区（设计稿 min-h-160）
                            TextField("分享你此刻的想法...", text: $content, axis: .vertical)
                                .font(.vibeBody)
                                .foregroundColor(.white)
                                .lineLimit(5...10)
                                .frame(minHeight: 160, alignment: .top)

                            // 分隔线
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)

                            // 标签区
                            tagInputSection
                        }
                        .padding(24)
                        .glassCard(cornerRadius: 32)

                        // 链接输入（仅 link 类型 — 保留但不在默认 Tab 里）
                        if selectedType == .link {
                            linkInputSection
                        }

                        // 媒体上传区
                        if [.image, .video, .audio].contains(selectedType) {
                            mediaUploadSection
                        }

                        // 发布按钮 + 底部选项
                        VStack(spacing: 16) {
                            Button {
                                Task { await publish() }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("发布动态")
                                        .font(.custom("PlusJakartaSans-ExtraBold", size: 18))
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 18))
                                }
                                .foregroundColor(.vibeIndigo)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: .white.opacity(0.3), radius: 10, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle(scale: 0.97))
                            .disabled(isPublishing)

                            // 底部选项（设计稿：添加位置 + 谁可以看）
                            HStack(spacing: 24) {
                                Button {
                                    // TODO: 位置
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 16))
                                        Text("添加位置")
                                            .font(.vibeCaption)
                                    }
                                    .foregroundColor(.vibeTextSecondary)
                                }

                                Button {
                                    // TODO: 可见性
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 16))
                                        Text("仅自己可见")
                                            .font(.vibeCaption)
                                    }
                                    .foregroundColor(.vibeTextSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
    }

    // 标签输入区
    private var tagInputSection: some View {
        FlowLayout(spacing: 8) {
            // 已选标签
            ForEach(tags, id: \.self) { tag in
                HStack(spacing: 4) {
                    Text("#\(tag)")
                        .font(.vibeCaption)
                        .foregroundColor(.vibeTextSecondary)
                    Button {
                        tags.removeAll { $0 == tag }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(.vibeTextTertiary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.vibeTagBg)
                .clipShape(Capsule())
            }

            // 推荐标签（未添加的显示为可点击）
            ForEach(suggestedTags, id: \.self) { tag in
                if !tags.contains(tag) {
                    Button {
                        tags.append(tag)
                    } label: {
                        Text("#\(tag)")
                            .font(.vibeCaption)
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.vibeTagBg)
                            .clipShape(Capsule())
                    }
                }
            }

            // 添加标签输入
            TextField("添加标签", text: $tagInput)
                .font(.vibeCaption)
                .foregroundColor(.white)
                .frame(width: 80)
                .onSubmit {
                    let t = tagInput.trimmingCharacters(in: .whitespaces)
                    if !t.isEmpty && !tags.contains(t) { tags.append(t) }
                    tagInput = ""
                }
        }
    }

    // 链接输入
    private var linkInputSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.vibeTextTertiary)
                TextField("粘贴链接...", text: $linkURL)
                    .font(.vibeBody)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(16)
            .background(Color.vibeInputBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if isLoadingPreview {
                ProgressView().tint(.white)
            }

            if let preview = linkPreview {
                LinkCardView(link: LinkInfo(
                    url: preview.url,
                    title: preview.title,
                    description: preview.description,
                    thumbnailURL: preview.thumbnailURL,
                    domain: preview.domain
                ))
            }
        }
        .padding(20)
        .glassCard()
        .onChange(of: linkURL) { _, newValue in
            guard newValue.count > 10, !isLoadingPreview else { return }
            Task { await fetchPreview() }
        }
    }

    // 媒体上传区
    private var mediaUploadSection: some View {
        VStack(spacing: 12) {
            // 图标在圆角方块内（设计稿：w-16 h-16 bg-white/10 rounded-3xl）
            Image(systemName: "cloud.upload.fill")
                .font(.system(size: 28))
                .foregroundColor(Color.white.opacity(0.8))
                .frame(width: 64, height: 64)
                .background(Color.vibeInputBg)
                .clipShape(RoundedRectangle(cornerRadius: 24))

            Text("上传媒体文件")
                .font(.vibeBody)
                .foregroundColor(.white)

            Text(supportedFormatHint)
                .font(.vibeCaption)
                .foregroundColor(.vibeTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .glassCard(cornerRadius: 32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(Color.white.opacity(0.3))
        )
    }

    private var supportedFormatHint: String {
        switch selectedType {
        case .image: return "支持图片 (JPG/PNG/HEIC)"
        case .video: return "支持视频 (MP4/MOV)"
        case .audio: return "支持音频 (MP3/M4A/AAC)"
        default: return ""
        }
    }

    // 发布
    private func publish() async {
        isPublishing = true
        do {
            var link: LinkInfo? = nil
            if selectedType == .link, let p = linkPreview {
                link = LinkInfo(url: p.url, title: p.title, description: p.description, thumbnailURL: p.thumbnailURL, domain: p.domain)
            }
            _ = try await RecordService.shared.create(
                type: selectedType,
                content: content,
                tags: tags,
                mediaIDs: [],
                link: link
            )
            dismiss()
        } catch {
            print("发布失败: \(error)")
        }
        isPublishing = false
    }

    // 获取链接预览
    private func fetchPreview() async {
        isLoadingPreview = true
        do {
            linkPreview = try await LinkService.shared.preview(url: linkURL)
        } catch {
            // 静默失败
        }
        isLoadingPreview = false
    }
}

// 简单的 FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth + size.width > maxWidth {
                width = max(width, lineWidth)
                height += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }

        width = max(width, lineWidth)
        height += lineHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxX = bounds.maxX
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
