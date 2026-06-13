//
//  CreateRecordView.swift
//  Vibe
//
//  创建记录页 — 基于设计稿 03
//

import SwiftUI

struct CreateRecordView: View {
    @State private var selectedType: RecordType = .text
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var tagInput = ""
    @State private var linkURL = ""
    @State private var linkPreview: LinkPreviewResult?
    @State private var isLoadingPreview = false
    @State private var isPublishing = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 类型 Tab
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(RecordType.allCases, id: \.self) { type in
                                Button {
                                    selectedType = type
                                } label: {
                                    Text(type.label)
                                        .font(.vibeBodySmall)
                                        .foregroundColor(selectedType == type ? .vibeIndigo : .white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(selectedType == type ? Color.white : Color.vibeCardBg)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }

                    // 文字输入
                    VStack(spacing: 16) {
                        TextField("分享你此刻的想法...", text: $content, axis: .vertical)
                            .font(.vibeBody)
                            .foregroundColor(.white)
                            .lineLimit(3...8)

                        Divider().overlay(Color.vibeCardBorder)

                        // 标签输入
                        tagInputSection
                    }
                    .padding(20)
                    .glassCard()

                    // 链接输入（仅 link 类型）
                    if selectedType == .link {
                        linkInputSection
                    }

                    // 媒体上传区（image/video/audio）
                    if [.image, .video, .audio].contains(selectedType) {
                        mediaUploadSection
                    }

                    // 发布按钮
                    Button {
                        Task { await publish() }
                    } label: {
                        HStack(spacing: 8) {
                            Text("发布动态")
                            Image(systemName: "paperplane.fill")
                        }
                        .font(.vibeBody)
                        .foregroundColor(.vibeIndigo)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .white.opacity(0.3), radius: 10, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(isPublishing)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .navigationTitle("发布新动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.vibeTextSecondary)
                }
            }
        }
    }

    // 标签输入
    private var tagInputSection: some View {
        FlowLayout(spacing: 8) {
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
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.vibeTagBg)
                .clipShape(Capsule())
            }

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
            Image(systemName: "cloud.upload.fill")
                .font(.system(size: 32))
                .foregroundColor(.vibeTextSecondary)

            Text("上传媒体文件")
                .font(.vibeBody)
                .foregroundColor(.white)

            Text("支持 \(selectedType.label) 格式")
                .font(.vibeCaption)
                .foregroundColor(.vibeTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.vibeCardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(Color.vibeCardBorder)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
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
