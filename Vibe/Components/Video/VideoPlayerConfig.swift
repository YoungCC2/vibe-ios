//
//  VideoPlayerConfig.swift
//  Vibe
//
//  视频播放器统一配置 — 所有视频组件共用
//

import SwiftUI

/// 视频播放器配置
struct VideoPlayerConfig {
    /// 是否自动播放
    var autoPlay: Bool = true
    /// 是否循环播放
    var loopPlayback: Bool = true
    /// 是否显示系统控制面板（进度条/暂停等）
    var showsControls: Bool = true
    /// 是否静音（信息流场景通常静音）
    var muted: Bool = false
    /// 画面比例
    var aspectRatio: CGFloat? = 4.0 / 5.0
    /// 圆角
    var cornerRadius: CGFloat = 24
    /// 是否允许全屏
    var allowsFullscreen: Bool = true

    /// 信息流默认配置（静音+自动播放+循环+无控制面板）
    static let feed = VideoPlayerConfig(
        autoPlay: true,
        loopPlayback: true,
        showsControls: false,
        muted: true,
        aspectRatio: 4.0 / 5.0,
        cornerRadius: 24,
        allowsFullscreen: true
    )

    /// 全屏播放配置（有声+控制面板）
    static let fullscreen = VideoPlayerConfig(
        autoPlay: true,
        loopPlayback: false,
        showsControls: true,
        muted: false,
        aspectRatio: nil,
        cornerRadius: 0,
        allowsFullscreen: false
    )
}
