#!/usr/bin/env python3
"""
Vibe App Logo Generator
紫蓝渐变 + 波形设计
输出：1024x1024 App Icon + 各尺寸
"""
import subprocess, os, sys

SVG = '''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs>
    <!-- 紫蓝渐变背景 -->
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1A1A2E"/>
      <stop offset="100%" stop-color="#16213E"/>
    </linearGradient>
    <!-- 波形渐变 紫蓝 -->
    <linearGradient id="waveGrad" x1="0%" y1="50%" x2="100%" y2="50%">
      <stop offset="0%" stop-color="#6C5CE7"/>
      <stop offset="100%" stop-color="#0984E3"/>
    </linearGradient>
    <!-- 发光效果 -->
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <!-- 圆角背景 -->
  <rect width="1024" height="1024" rx="224" fill="url(#bgGrad)"/>

  <!-- 波形条 — 5根，中间高两边低，模拟声波/音浪 -->
  <g filter="url(#glow)">
    <!-- 左1 (短) -->
    <rect x="282" y="380" width="64" height="264" rx="32" fill="url(#waveGrad)" opacity="0.55"/>
    <!-- 左2 (中) -->
    <rect x="394" y="304" width="64" height="416" rx="32" fill="url(#waveGrad)" opacity="0.75"/>
    <!-- 中间 (最高) -->
    <rect x="506" y="232" width="64" height="560" rx="32" fill="url(#waveGrad)" opacity="1"/>
    <!-- 右2 (中) -->
    <rect x="618" y="304" width="64" height="416" rx="32" fill="url(#waveGrad)" opacity="0.75"/>
    <!-- 右1 (短) -->
    <rect x="730" y="380" width="64" height="264" rx="32" fill="url(#waveGrad)" opacity="0.55"/>
  </g>

  <!-- 底部微光反射 -->
  <ellipse cx="512" cy="860" rx="240" ry="16" fill="url(#waveGrad)" opacity="0.08"/>
</svg>'''

SVG_PATH = "/tmp/vibe_logo.svg"
PNG_PATH = "/tmp/vibe_logo_1024.png"

# 写 SVG
with open(SVG_PATH, "w") as f:
    f.write(SVG)

print("✅ SVG generated")

# 检查可用的转换工具
def has(cmd):
    return subprocess.run(["which", cmd], capture_output=True).returncode == 0

if has("rsvg-convert"):
    subprocess.run(["rsvg-convert", "-w", "1024", "-h", "1024", SVG_PATH, "-o", PNG_PATH], check=True)
    print(f"✅ PNG 1024x1024 (rsvg-convert) → {PNG_PATH}")
elif has("convert"):
    subprocess.run(["convert", "-density", "300,300", "-resize", "1024x1024", SVG_PATH, PNG_PATH], check=True)
    print(f"✅ PNG 1024x1024 (ImageMagick) → {PNG_PATH}")
elif has("sips"):
    # 先用 qlmanage 生成
    subprocess.run(["qlmanage", "-t", "-s", "1024", "-o", "/tmp/", SVG_PATH], capture_output=True)
    import glob
    pngs = glob.glob("/tmp/vibe_logo.svg.png")
    if pngs:
        os.rename(pngs[0], PNG_PATH)
        print(f"✅ PNG 1024x1024 (qlmanage) → {PNG_PATH}")
    else:
        print("❌ qlmanage failed")
        sys.exit(1)
else:
    print("❌ No SVG to PNG converter found (need rsvg-convert, convert, or sips)")
    sys.exit(1)

# 生成 iOS 各尺寸
SIZES = [
    (20, "20pt"),   (29, "29pt"),   (40, "40pt"),
    (60, "60pt"),   (76, "76pt"),   (83.5, "83.5pt"),
]

ICONSET = "/tmp/AppIcon.appiconset"
os.makedirs(ICONSET, exist_ok=True)

for size, _ in SIZES:
    s = int(size * 2)  # @2x
    out = f"{ICONSET}/icon_{s}x{s}.png"
    subprocess.run(["sips", "-z", str(s), str(s), PNG_PATH, "--out", out], capture_output=True)

# 1024 for App Store
subprocess.run(["cp", PNG_PATH, f"{ICONSET}/icon_1024x1024.png"])
print(f"✅ Generated icon set → {ICONSET}")
print(f"✅ Preview: {PNG_PATH}")
