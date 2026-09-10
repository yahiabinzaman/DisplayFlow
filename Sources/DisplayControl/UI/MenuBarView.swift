import SwiftUI

public struct MenuBarView: View {
    @ObservedObject var manager = DisplayManager.shared
    @ObservedObject var launchManager = LaunchAtLoginManager.shared
    @ObservedObject var batteryMonitor = BatteryMonitor.shared
    
    @State private var showSettings: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Header Bar
            HStack(alignment: .center) {
                Text("Display")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Settings Toggle
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                    }
                }) {
                    Image(systemName: showSettings ? "gearshape.fill" : "gearshape")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(showSettings ? Color(nsColor: .controlAccentColor) : .secondary)
                }
                .buttonStyle(.plain)
                .help("Settings & Shortcuts")
                
                // Refresh Button
                Button(action: {
                    withAnimation {
                        manager.refreshDisplays()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Refresh Connected Displays")
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
            if showSettings {
                // Settings & Shortcuts Card
                VStack(alignment: .leading, spacing: 10) {
                    Text("Preferences & Hotkeys")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    // Launch at Login Toggle
                    Toggle(isOn: $launchManager.isEnabled) {
                        Label("Start at Login", systemImage: "bolt.badge.automatic")
                            .font(.system(size: 11))
                    }
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    
                    // Smart Battery Eco Mode (if Mac has battery)
                    if batteryMonitor.hasBattery {
                        Toggle(isOn: $manager.autoBatteryEcoEnabled) {
                            Label("Auto Eco on Battery (60Hz)", systemImage: "battery.50")
                                .font(.system(size: 11))
                        }
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                    }
                    
                    Divider()
                        .opacity(0.4)
                    
                    // Keyboard Shortcuts
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Keyboard Shortcuts:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("⌥ ⇧ R")
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .background(Color.secondary.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            Text("Toggle Refresh Rate (60Hz ⟷ Max)")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("⌥ ⇧ ↑/↓")
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .background(Color.secondary.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            Text("Adjust Brightness (±10%)")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
                )
                .padding(.horizontal, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Displays List
            VStack(spacing: 10) {
                if manager.displays.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "display.trianglebadge.exclamationmark")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                        Text("No Displays Detected")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(manager.displays) { display in
                        DisplayCardView(display: display)
                    }
                }
            }
            .padding(.horizontal, 14)
            
            // Quick Modes / Presets
            HStack(spacing: 8) {
                PresetModuleButton(
                    title: "Eco Mode",
                    icon: "leaf.fill",
                    isSelected: manager.selectedPreset == "Eco"
                ) {
                    manager.applyEcoMode()
                }
                
                PresetModuleButton(
                    title: "Pro / Max Hz",
                    icon: "bolt.fill",
                    isSelected: manager.selectedPreset == "ProMotion"
                ) {
                    manager.applyProMotionMode()
                }
                
                PresetModuleButton(
                    title: "Night Dim",
                    icon: "moon.fill",
                    isSelected: manager.selectedPreset == "Night"
                ) {
                    manager.applyNightMode()
                }
            }
            .padding(.horizontal, 14)
            
            Divider()
                .opacity(0.4)
                .padding(.horizontal, 10)
            
            // Footer: Subtle native style
            VStack(spacing: 6) {
                HStack {
                    Text("\(manager.displays.count) Display\(manager.displays.count == 1 ? "" : "s") Active")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Text("Quit")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    if let url = URL(string: "https://github.com/yahiabinzaman") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 3) {
                        Text("Developed by")
                            .foregroundColor(Color.secondary.opacity(0.7))
                        Text("Yahia Bin Zaman")
                            .foregroundColor(Color(nsColor: .controlAccentColor))
                    }
                    .font(.system(size: 10, weight: .medium))
                }
                .buttonStyle(.plain)
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .frame(width: 330)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
    }
}

// Native Apple Control Center Style Preset Module
struct PresetModuleButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(nsColor: .controlAccentColor))
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        isSelected
                        ? Color(nsColor: .controlAccentColor)
                        : Color(nsColor: .quaternaryLabelColor).opacity(0.25)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// Visual Effect View for Native macOS Translucent Material
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
