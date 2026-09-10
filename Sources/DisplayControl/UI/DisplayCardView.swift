import SwiftUI

public struct DisplayCardView: View {
    let display: DisplayModel
    @ObservedObject var manager = DisplayManager.shared
    
    @State private var localBrightness: Double
    @State private var localWarmth: Double
    
    public init(display: DisplayModel) {
        self.display = display
        _localBrightness = State(initialValue: Double(display.brightness))
        _localWarmth = State(initialValue: Double(display.warmth))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Display Info & Badges
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(nsColor: .controlAccentColor).opacity(0.18))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: display.isBuiltin ? "laptopcomputer" : "display")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(nsColor: .controlAccentColor))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(display.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if display.isMain {
                            Text("MAIN")
                                .font(.system(size: 8.5, weight: .bold))
                                .padding(.horizontal, 4.5)
                                .padding(.vertical, 1.5)
                                .background(Color(nsColor: .controlAccentColor).opacity(0.15))
                                .foregroundColor(Color(nsColor: .controlAccentColor))
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Resolution menu inside header subtitle
                    Menu {
                        ForEach(display.availableResolutions.prefix(10)) { res in
                            Button(action: {
                                manager.setResolution(for: display, resolution: res)
                            }) {
                                HStack {
                                    Text(res.title)
                                    if (res.width == display.width && res.height == display.height) ||
                                       (res.pixelWidth == display.pixelWidth && res.pixelHeight == display.pixelHeight) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(display.resolutionString)
                                .font(.system(size: 11, weight: .regular))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 8))
                        }
                        .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                }
                
                Spacer()
                
                // Active Hz Badge
                Text(display.formattedCurrentHz)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(nsColor: .quaternaryLabelColor).opacity(0.4))
                    .clipShape(Capsule())
            }
            
            // Brightness Control (Apple Control Center Capsule Slider)
            VStack(alignment: .leading, spacing: 4) {
                Text("Display Brightness")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                ControlCenterSlider(
                    value: $localBrightness,
                    iconName: "sun.max.fill",
                    activeColor: .white
                ) { editing in
                    if !editing {
                        manager.setBrightness(for: display, brightness: Float(localBrightness))
                    }
                }
                .onChange(of: localBrightness) { newValue in
                    manager.setBrightness(for: display, brightness: Float(newValue))
                }
            }
            
            // Refresh Rate (Hz) Segmented Bar
            VStack(alignment: .leading, spacing: 4) {
                Text("Refresh Rate")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 0) {
                    ForEach(display.availableRefreshRates, id: \.self) { rate in
                        let isSelected = abs(display.currentRefreshRate - rate) < 0.1
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                manager.setRefreshRate(for: display, rate: rate)
                            }
                        }) {
                            Text(display.formattedHz(rate))
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(
                                    isSelected
                                    ? Color(nsColor: .controlAccentColor)
                                    : Color.clear
                                )
                                .foregroundColor(isSelected ? .white : .primary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if rate != display.availableRefreshRates.last && !isSelected {
                            Divider()
                                .frame(height: 12)
                                .opacity(0.3)
                        }
                    }
                }
                .background(Color(nsColor: .quaternaryLabelColor).opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                )
            }
            
            // Night Shift / Warmth Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Night Shift Warmth")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                ControlCenterSlider(
                    value: $localWarmth,
                    iconName: "sun.horizon.fill",
                    activeColor: Color.orange.opacity(0.9),
                    iconColor: .orange
                ) { editing in
                    if !editing {
                        manager.setWarmth(for: display, warmth: Float(localWarmth))
                    }
                }
                .onChange(of: localWarmth) { newValue in
                    manager.setWarmth(for: display, warmth: Float(newValue))
                }
            }
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .onChange(of: display.brightness) { newValue in
            localBrightness = Double(newValue)
        }
        .onChange(of: display.warmth) { newValue in
            localWarmth = Double(newValue)
        }
    }
}
