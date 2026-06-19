//
//  VideoTestView.swift
//  Vibe
//
//  临时调试页面：测试视频封面加载
//

import SwiftUI

struct VideoTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("视频封面测试")
                    .font(.title)

                // 测试 1: 直接用完整 URL
                VStack {
                    Text("测试1: 直接URL")
                        .font(.caption)
                    let url = URL(string: "https://static.yhugo.cn/zywoo/video/2026/06/7d03344f-a8b7-42f1-8f75-6f3fc24637b3.mp4?vframe/jpg/offset/1")
                    Text("URL: \(url?.absoluteString ?? "nil")")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)

                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(4.0/5.0, contentMode: .fit)
                        .overlay {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Color.red.opacity(0.3)
                                        .overlay(Text("❌ 加载失败").foregroundColor(.white))
                                case .empty:
                                    Color.blue.opacity(0.3)
                                        .overlay(Text("⏳ 加载中...").foregroundColor(.white))
                                @unknown default:
                                    Color.gray
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

                // 测试 2: 普通图片 URL（对照组）
                VStack {
                    Text("测试2: 对照组图片")
                        .font(.caption)
                    let url2 = URL(string: "https://static.yhugo.cn/zywoo/image/2026/06/test.jpg")
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(4.0/5.0, contentMode: .fit)
                        .overlay {
                            AsyncImage(url: url2) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Color.red.opacity(0.3)
                                        .overlay(Text("❌ 加载失败").foregroundColor(.white))
                                case .empty:
                                    Color.blue.opacity(0.3)
                                        .overlay(Text("⏳ 加载中...").foregroundColor(.white))
                                @unknown default:
                                    Color.gray
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .padding()
        }
    }
}
