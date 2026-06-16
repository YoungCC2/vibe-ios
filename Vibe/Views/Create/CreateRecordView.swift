//
//  CreateRecordView.swift
//  Vibe
//
//  创建记录页 — 基于设计稿 01.md
//

import SwiftUI
import PhotosUI

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

    // 媒体选择 & 上传状态
    @State private var pickedMedia: [PickedMedia] = []
    @State private var uploadedIDs: [UInt64] = []
    @State private var uploadProgress: [UUID: Double] = [:]
    @State private var mediaIDMap: [UUID: UInt64] = [:]

    // 位置
    @State private var locationName: String?
    @State private var isLocating = false
    @StateObject private var locationService = LocationService.shared

    @Environment(\.dismiss) var dismiss

    // 支持全部5种类型
    private let createTypes: [RecordType] = [.text, .image, .video, .audio, .link]
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
                                HStack(spacing: 6) {
                                    Text("发布动态")
                                        .font(.custom("PlusJakartaSans-ExtraBold", size: 14))
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.vibeIndigo)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .white.opacity(0.3), radius: 6, y: 3)
                            }
                            .buttonStyle(ScaleButtonStyle(scale: 0.97))
                            .disabled(isPublishing)

                            // 底部选项
                            HStack(spacing: 24) {
                                Button {
                                    Task {
                                        isLocating = true
                                        let name = await locationService.requestLocationName()
                                        locationName = name
                                        isLocating = false
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        if isLocating {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                                .frame(width: 16, height: 16)
                                        } else {
                                            Image(systemName: locationName != nil ? "location.fill" : "location")
                                                .font(.system(size: 16))
                                        }
                                        Text(locationName ?? "添加位置")
                                            .font(.vibeCaption)
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.vibeTextSecondary)
                                }

                                if locationName != nil {
                                    Button {
                                        locationName = nil
                                        locationService.clearLocation()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.vibeTextTertiary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .scrollDismissesKeyboard(.interactively)
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
        VStack(spacing: 16) {
            // 已选择的媒体预览
            if !pickedMedia.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(pickedMedia) { media in
                            mediaPreviewCell(media)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            // 上传按钮（或重新选择）
            MediaPickerButton(type: selectedType) { picked in
                handlePickedMedia(picked)
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "cloud.upload.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.white.opacity(0.8))
                        .frame(width: 64, height: 64)
                        .background(Color.vibeInputBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24))

                    Text(pickedMedia.isEmpty ? "上传媒体文件" : "继续添加")
                        .font(.vibeBody)
                        .foregroundColor(.white)

                    Text(supportedFormatHint)
                        .font(.vibeCaption)
                        .foregroundColor(.vibeTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundColor(Color.white.opacity(0.3))
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // 单个媒体预览格
    private func mediaPreviewCell(_ media: PickedMedia) -> some View {
        let progress = uploadProgress[media.id] ?? 0
        let isDone = progress >= 1.0

        return ZStack(alignment: .topTrailing) {
            // 缩略图或占位
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.vibeInputBg)
                .frame(width: 100, height: 100)
                .overlay {
                    if let thumb = media.thumbnailImage {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        // 音频或加载中
                        Image(systemName: media.type == .audio ? "waveform" : "doc.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.vibeTextTertiary)
                    }
                }

            // 上传状态遮罩
            if !isDone {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .overlay {
                        VStack(spacing: 6) {
                            ProgressView(value: progress)
                                .tint(.white)
                                .frame(width: 60)
                            Text("上传中")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
            }

            // 删除按钮
            Button {
                removeMedia(media.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.3)))
            }
            .padding(6)
        }
        .frame(width: 100, height: 100)
    }

    private var supportedFormatHint: String {
        switch selectedType {
        case .image: return "支持图片 (JPG/PNG/HEIC)"
        case .video: return "支持视频 (MP4/MOV)"
        case .audio: return "支持音频 (MP3/M4A/AAC)"
        default: return ""
        }
    }

    // MARK: - 媒体选择 & 上传

    private func handlePickedMedia(_ picked: PickedMedia) {
        pickedMedia.append(picked)
        uploadProgress[picked.id] = 0.0

        Task {
            do {
                // 模拟进度更新（实际上传是单次请求，这里给一个乐观进度）
                await MainActor.run {
                    uploadProgress[picked.id] = 0.3
                }

                let result = try await UploadService.shared.upload(
                    data: picked.data,
                    fileName: picked.fileName,
                    mimeType: picked.mimeType,
                    type: picked.type.rawValue
                )

                await MainActor.run {
                    uploadProgress[picked.id] = 1.0
                    mediaIDMap[picked.id] = result.mediaID
                    uploadedIDs.append(result.mediaID)
                }
            } catch {
                print("上传失败: \(error)")
                await MainActor.run {
                    uploadProgress[picked.id] = -1.0  // 标记失败
                }
            }
        }
    }

    private func removeMedia(_ id: UUID) {
        pickedMedia.removeAll { $0.id == id }
        uploadProgress.removeValue(forKey: id)
        if let mediaID = mediaIDMap.removeValue(forKey: id) {
            uploadedIDs.removeAll { $0 == mediaID }
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
                mediaIDs: uploadedIDs,
                link: link,
                locationName: locationName
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
