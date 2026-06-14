//
//  MediaPickerButton.swift
//  Vibe
//
//  媒体选择按钮 — 统一封装 PhotosPicker / fileImporter
//  支持图片、视频、音频三种类型
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation

/// 媒体选择结果
struct PickedMedia: Identifiable {
    let id = UUID()
    let data: Data
    let fileName: String
    let mimeType: String
    let type: RecordType
    var thumbnailImage: UIImage?   // 图片/视频缩略图
}

/// 统一媒体选择器
/// 用法：
///   MediaPickerButton(type: .image) { picked in ... }
struct MediaPickerButton<Label: View>: View {
    let type: RecordType
    let onPicked: (PickedMedia) -> Void
    @ViewBuilder var label: () -> Label

    @State private var photoItem: PhotosPickerItem?
    @State private var showFilePicker = false

    var body: some View {
        switch type {
        case .image:
            PhotosPicker(selection: $photoItem, matching: .images) {
                label()
            }
            .onChange(of: photoItem) { _, item in
                handlePhotoItem(item, type: .image)
            }
        case .video:
            PhotosPicker(selection: $photoItem, matching: .videos) {
                label()
            }
            .onChange(of: photoItem) { _, item in
                handlePhotoItem(item, type: .video)
            }
        case .audio:
            Button { showFilePicker = true } label: { label() }
                .fileImporter(isPresented: $showFilePicker, allowedContentTypes: audioTypes, allowsMultipleSelection: false) { result in
                    handleFileResult(result)
                }
        default:
            EmptyView()
        }
    }

    // MARK: - Filters

    private var audioTypes: [UTType] {
        [.mp3, .mpeg4Audio, .wav, .audio]
    }

    // MARK: - Handlers

    private func handlePhotoItem(_ item: PhotosPickerItem?, type: RecordType) {
        guard let item else { return }
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else { return }

                var thumb: UIImage? = nil
                if type == .image {
                    thumb = UIImage(data: data)
                } else if type == .video {
                    thumb = await generateVideoThumbnail(from: data)
                }

                let fileName = "\(UUID().uuidString).\(type == .image ? "jpg" : "mp4")"
                let mimeType = type == .image ? "image/jpeg" : "video/mp4"

                await MainActor.run {
                    onPicked(PickedMedia(data: data, fileName: fileName, mimeType: mimeType, type: type, thumbnailImage: thumb))
                }
            } catch {
                print("PhotosPicker load error: \(error)")
            }
        }
    }

    private func handleFileResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }
            guard let data = try? Data(contentsOf: url) else { return }
            let fileName = url.lastPathComponent
            let mime = mimeTypeForPath(url.path)
            onPicked(PickedMedia(data: data, fileName: fileName, mimeType: mime, type: .audio, thumbnailImage: nil))
        case .failure(let error):
            print("File picker error: \(error)")
        }
    }

    // MARK: - Helpers

    private func mimeTypeForPath(_ path: String) -> String {
        let ext = (path as NSString).pathExtension.lowercased()
        switch ext {
        case "mp3": return "audio/mpeg"
        case "m4a": return "audio/mp4"
        case "aac": return "audio/aac"
        case "wav": return "audio/wav"
        case "caf": return "audio/x-caf"
        default: return "audio/mpeg"
        }
    }

    private func generateVideoThumbnail(from data: Data) async -> UIImage? {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("thumb_\(UUID().uuidString).mp4")
        do {
            try data.write(to: tmpURL)
            let asset = AVAsset(url: tmpURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let cgImage = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<CGImage, Error>) in
                generator.generateCGImageAsynchronously(for: CMTime(seconds: 1, preferredTimescale: 600)) { image, _, error in
                    if let image { cont.resume(returning: image) }
                    else if let error { cont.resume(throwing: error) }
                }
            }
            try? FileManager.default.removeItem(at: tmpURL)
            return UIImage(cgImage: cgImage)
        } catch {
            try? FileManager.default.removeItem(at: tmpURL)
            return nil
        }
    }
}
