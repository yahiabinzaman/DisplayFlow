# Display Control for macOS 🖥️⚡

A native, lightweight macOS Menu Bar app built in **Swift & SwiftUI** with Apple Control Center aesthetics to control **Refresh Rates (Hz)**, **Screen Brightness**, **Color Warmth (Night Shift)**, **Resolutions**, **Blackout**, and **Smart Battery Automation**.

---

## ✨ Full Feature Suite

### 1. ⚡ Refresh Rate (Hz) Switching
- Instantly switch display refresh rates (**60Hz**, **75Hz**, **100Hz**, **120Hz ProMotion**, **144Hz**, etc.) with native segmented control.

### 2. ☀️ Apple Control Center Brightness Slider
- Smooth capsule slider with embedded SF Symbol icon and interactive percentage badge.
- Native hardware integration via macOS `DisplayServices` + software dimming fallback.

### 3. 🌡️ Night Warmth & Blue-Light Filter
- Smooth color temperature slider (Cool to Warm Amber) for eye protection during night work.

### 4. 🖥️ Display Resolution & Scaling Selector
- Change resolutions directly from the menu bar (supports HiDPI Retina modes).

### 5. 🌑 Screen Blackout / Sleep Individual Monitor
- Click the eye icon to instantly blackout/sleep an individual monitor in multi-screen setups.

### 6. 🔋 Smart Battery Auto-Eco Mode
- Automatically switches to 60Hz and dims screen when on battery power.
- Automatically restores max refresh rate (120Hz/144Hz) when connected to MagSafe / charger.

### 7. 🚀 Launch at Login
- One-click toggle to automatically start Display Control on system boot.

### 8. ⌨️ Global Keyboard Shortcuts (Hotkeys)
- **`⌥ + ⇧ + R`** : Instant Refresh Rate Toggle (60Hz ⟷ Max Hz)
- **`⌥ + ⇧ + ↑ / ↓`** : Brightness Up / Down (±10%)
- **`⌥ + ⇧ + B`** : Toggle Screen Blackout

---

## 🚀 How to Run

### Open the App Directly:
```bash
open DisplayControl.app
```

### Add to Applications Folder:
```bash
cp -R DisplayControl.app /Applications/
```

### Rebuild from Source:
```bash
./build_app.sh
```

---

*Developed by [Yahia Bin Zaman](https://github.com/yahiabinzaman)*
