//
//  AppLogo.swift
//  Vibe
//
//  紫蓝波形 Logo 组件
//

import SwiftUI

struct AppLogo: View {
    var size: CGFloat = 64
    
    var body: some View {
        // 用 Canvas 绘制波形 logo，不依赖图片资源
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            
            // 圆角背景渐变
            let bgRect = CGRect(x: 0, y: 0, width: w, height: h)
            let bgPath = Path(roundedRect: bgRect, cornerRadius: w * 0.22)
            
            // 背景：深色渐变
            let bgGradient = Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.18),    // #1A1A2E
                Color(red: 0.09, green: 0.13, blue: 0.24)   // #16213E
            ])
            context.fill(bgPath, with: .linearGradient(
                bgGradient,
                startPoint: .zero,
                endPoint: CGPoint(x: w, y: h)
            ))
            
            // 波形条参数 (相对坐标)
            let bars: [(x: Double, heightRatio: Double, opacity: Double)] = [
                (0.276, 0.258, 0.55),
                (0.385, 0.406, 0.75),
                (0.494, 0.547, 1.0),
                (0.604, 0.406, 0.75),
                (0.713, 0.258, 0.55),
            ]
            
            let barWidth = w * 0.0625
            let centerY = h * 0.5
            
            // 波形渐变色: #6C5CE7 → #0984E3
            let waveGradient = Gradient(colors: [
                Color(red: 0.42, green: 0.36, blue: 0.91),
                Color(red: 0.035, green: 0.518, blue: 0.89)
            ])
            
            for bar in bars {
                let barH = h * bar.heightRatio
                let barX = w * bar.x
                let barY = centerY - barH / 2
                let barRect = CGRect(x: barX, y: barY, width: barWidth, height: barH)
                let barPath = Path(roundedRect: barRect, cornerRadius: barWidth * 0.5)
                
                context.opacity = bar.opacity
                context.fill(barPath, with: .linearGradient(
                    waveGradient,
                    startPoint: CGPoint(x: barX, y: centerY),
                    endPoint: CGPoint(x: barX + barWidth, y: centerY)
                ))
            }
            
            context.opacity = 1.0
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        .shadow(color: .black.opacity(0.25), radius: size * 0.2, y: size * 0.1)
    }
}

#Preview {
    AppLogo(size: 120)
        .padding(40)
}
