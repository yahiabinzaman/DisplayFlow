import SwiftUI

public struct DisplayCardView: View {
    let display: DisplayModel
    @ObservedObject var manager = DisplayManager.shared
    
    @State private var localBrightness: Double
    @State private var localWarmth: Double
    @State private var showAdvanced: Bool = false
    
    public init(display: DisplayModel) {
        self.display = display
        _localBrightness = State(initialValue: Double(display.brightness))
        _localWarmth = State(initialValue: Double(display.warmth))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Display Info & Actions
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(nsColor: .controlAccentColor).opacity(0.18))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: display.isBuiltin ? "laptopcomputer" : "display")
                        .font(.system(size: 16, weight: .semibold))
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
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(Color(nsColor: .controlAccentColor).opacity(0.15))
                                .foregroundColor(Color(nsColor: .controlAccentColor))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(display.resolutionString)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
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
            VStack(alignment: .leading, spacing: 5) {
                Text("Display Brightness")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                ControlCenterSlider(
                    value: $localBrightness,
                    iconName: "sun.max.fill"
                ) { editing in
                    if !editing {
                        manager.setBrightness(for: display, brightness: Float(localBrightness))
                    }
                }
                .onChange(of: localBrightness) { newValue in
                    manager.setBrightness(for: display, brightness: Float(newValue))
                }
            }
            
            // Refresh Rate (Hz) Segmented Picker
            VStack(alignment: .leading, spacing: 5) {
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
            
            // Advanced Controls Toggle (Resolution & Color Warmth)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAdvanced.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: showAdvanced ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                    Text(showAdvanced ? "Hide More Controls" : "More Controls (Warmth, Resolution)")
                        .font(.system(size: 10.5, weight: .medium))
                    Spacer()
                }
                .foregroundColor(Color(nsColor: .controlAccentColor))
                .padding(.top, 2)
            }
            .buttonStyle(.plain)
            
            if showAdvanced {
                VStack(alignment: .leading, spacing: 10) {
                    // Color Warmth Slider
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Night Warmth / Blue Light")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(localWarmth * 100))%")
                                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        
                        ControlCenterSlider(
                            value: $localWarmth,
                            iconName: "sun.horizon.fill"
                        ) { editing in
                            if !editing {
                                manager.setWarmth(for: display, warmth: Float(localWarmth))
                            }
                        }
                        .onChange(of: localWarmth) { newValue in
                            manager.setWarmth(for: display, warmth: Float(newValue))
                        }
                    }
                    
                    // Resolution Selector
                    if !display.availableResolutions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Display Resolution")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(display.availableResolutions.prefix(12)) { res in
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
                                HStack {
                                    Image(systemName: "rectangle.inset.filled.and.cursorarrow")
                                        .font(.system(size: 11))
                                    Text(display.resolutionString)
                                        .font(.system(size: 11, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 9))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(nsColor: .quaternaryLabelColor).opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                            }
                            .menuStyle(.borderlessButton)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
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
