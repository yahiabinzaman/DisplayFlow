<div align="center">

# ⚡ DisplayFlow for macOS

### The Ultimate Native Menu Bar Controller for Display Refresh Rates (Hz), Brightness, Resolution & Battery Eco Mode.

<p align="center">
  <a href="https://github.com/yahiabinzaman/DisplayFlow/releases"><img src="https://img.shields.io/github/v/release/yahiabinzaman/DisplayFlow?color=blue&style=for-the-badge" alt="Release"></a>
  <a href="https://github.com/yahiabinzaman/DisplayFlow/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg?style=for-the-badge&logo=swift" alt="Swift 6.0"></a>
  <a href="https://apple.com/macos"><img src="https://img.shields.io/badge/macOS-13.0%2B-black.svg?style=for-the-badge&logo=apple" alt="macOS 13+"></a>
  <a href="https://github.com/yahiabinzaman/DisplayFlow/stargazers"><img src="https://img.shields.io/github/stars/yahiabinzaman/DisplayFlow?style=for-the-badge&color=yellow" alt="Stars"></a>
</p>

<p align="center">
  <b>A lightweight, 100% free and open-source alternative to BetterDisplay, Lunar, and MonitorControl.</b><br/>
  Crafted with native SwiftUI and Apple Control Center aesthetics for seamless performance on Apple Silicon (M1/M2/M3/M4) & Intel Macs.
</p>

---

[📥 Download Latest Release](https://github.com/yahiabinzaman/DisplayFlow/releases/latest) • [✨ Features](#-features) • [🚀 Quick Install](#-installation) • [⌨️ Hotkeys](#-global-keyboard-shortcuts) • [📊 Comparison](#-displayflow-vs-alternatives) • [🤝 Contributing](#-contributing)

</div>

---

## 💡 Why DisplayFlow?

macOS makes switching display refresh rates and adjusting external monitor brightness tedious. **DisplayFlow** brings fluid, 1-click controls right into your macOS Menu Bar, designed to look and feel like an official Apple system feature.

Whether you need **120Hz ProMotion / 144Hz** for gaming & video editing, **60Hz Eco Mode** to extend MacBook battery life, or smooth **external monitor brightness & night warmth**, DisplayFlow does it with zero bloat and zero background CPU usage.

---

## ✨ Features

### ⚡ Instant Refresh Rate (Hz) Switching
- Query and switch between all supported display refresh rates (**50Hz, 60Hz, 75Hz, 100Hz, 120Hz ProMotion, 144Hz, 240Hz**) in 1 click.
- Native segmented control UI matching macOS Control Center.

### ☀️ Apple Control Center Brightness Slider
- Smooth capsule slider with embedded SF Symbol icon and interactive live percentage.
- **Hardware DDC/CI & DisplayServices** private API integration for native Apple displays and external screens.
- Seamless software dimming fallback down to 0% blackout.

### 🌡️ Night Warmth & Blue-Light Filter (True Tone Alternative)
- Built-in color temperature slider (Cool White to Warm Amber) for eye protection during late-night coding.

### 🖥️ Resolution & HiDPI Retina Selector
- Instant resolution switcher with HiDPI 2x Retina mode detection directly from the menu bar.

### 🔋 Smart Battery Auto-Eco Switcher
- **On Battery**: Automatically drops refresh rate to 60Hz and optimizes brightness to prolong MacBook battery life.
- **On Charger**: Instantly restores maximum 120Hz/144Hz ProMotion smoothness when plugged into power.

### 🚀 Launch at Login
- Modern macOS 13+ `SMAppService` background launcher with zero overhead.

### ⌨️ Global Keyboard Shortcuts (Hotkeys)
- **`⌥ + ⇧ + R`** : Instant Refresh Rate Toggle (60Hz ⟷ Max Hz)
- **`⌥ + ⇧ + ↑ / ↓`** : Brightness Up / Down (±10%)

---

## 📊 DisplayFlow vs Alternatives

| Feature | DisplayFlow ⚡ | BetterDisplay | MonitorControl | QuickShade |
| :--- | :---: | :---: | :---: | :---: |
| **Price** | **100% Free & Open Source** | Freemium ($19+) | Free | Free |
| **Refresh Rate Switching (Hz)** | **Yes (1-Click)** | Yes (Pro) | ❌ No | ❌ No |
| **Apple Control Center UI** | **Native SwiftUI** | Custom UI | Basic Slider | Legacy UI |
| **Smart Battery 60Hz Eco Mode** | **Automated** | Pro Only | ❌ No | ❌ No |
| **Color Warmth / Blue Light Filter** | **Included** | Pro Only | ❌ No | ❌ No |
| **HiDPI Resolution Selector** | **Included** | Pro Only | ❌ No | ❌ No |
| **Apple Silicon M1/M2/M3/M4** | **Native (Universal)** | Native | Native | Native |
| **Telemetry / Tracking** | **Zero / Privacy-First** | Yes | Zero | Zero |

---

## 🚀 Installation

### Option 1: Direct Download (Recommended)
1. Download the latest `DisplayFlow.zip` from [**Releases**](https://github.com/yahiabinzaman/DisplayFlow/releases/latest).
2. Unzip and drag **DisplayFlow.app** into your `/Applications` folder.
3. Launch and enjoy!

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/yahiabinzaman/DisplayFlow.git
cd DisplayFlow

# Build and create standalone .app
./build_app.sh

# Open the app
open DisplayControl.app
```

---

## ⌨️ Global Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| <kbd>⌥ Option</kbd> + <kbd>⇧ Shift</kbd> + <kbd>R</kbd> | Toggle between 60Hz and Max Refresh Rate (120Hz/144Hz) |
| <kbd>⌥ Option</kbd> + <kbd>⇧ Shift</kbd> + <kbd>↑</kbd> | Increase brightness by 10% |
| <kbd>⌥ Option</kbd> + <kbd>⇧ Shift</kbd> + <kbd>↓</kbd> | Decrease brightness by 10% |

---

## 🛠️ Tech Stack & Requirements

- **Language**: Swift 6.0 + SwiftUI
- **Frameworks**: AppKit, CoreGraphics, DisplayServices, IOKit, ServiceManagement
- **OS Requirement**: macOS 13.0 (Ventura), macOS 14.0 (Sonoma), macOS 15.0+ (Sequoia)
- **Architecture**: Universal Binary (Apple Silicon ARM64 & Intel x86_64)

---

## 🤝 Contributing

Contributions, feature suggestions, and pull requests are warmly welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) to get started.

If you find DisplayFlow useful, please consider giving it a ⭐️ **Star** on GitHub!

---

## 📜 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for more information.

---

<div align="center">
  <b>Developed with ❤️ by <a href="https://github.com/yahiabinzaman">Yahia Bin Zaman</a></b>
</div>
