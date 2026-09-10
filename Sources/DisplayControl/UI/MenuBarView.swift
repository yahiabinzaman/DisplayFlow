import SwiftUI

public struct MenuBarView: View {
    @ObservedObject var manager = DisplayManager.shared
    @ObservedObject var launchManager = LaunchAtLoginManager.shared
    @ObservedObject var batteryMonitor = BatteryMonitor.shared
    
    @State private var showingSettings: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                settingsView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                mainDisplayView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .frame(width: 320)
        .animation(.easeInOut(duration: 0.22), value: showingSettings)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
    }
    
    // MARK: - Main Display View
    private var mainDisplayView: some View {
        VStack(spacing: 12) {
            // Header Bar
            HStack(alignment: .center) {
                Text("Display")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Preferences & Shortcuts")
                
                // Refresh Button
                Button(action: {
                    withAnimation {
                        manager.refreshDisplays()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color(nsColor: .quaternaryLabelColor).opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Refresh Connected Displays")
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
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
            
            // Footer
            VStack(spacing: 5) {
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
                    if let url = URL(string: "https://github.com/yahiabinzaman/DisplayFlow") {
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
    }
    
    // MARK: - Settings View (Apple Sub-Page Navigation)
    private var settingsView: some View {
        VStack(spacing: 12) {
            // Header with Back Button
            HStack {
                Button(action: {
                    showingSettings = false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .bold))
                        Text("Display")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(nsColor: .controlAccentColor))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Preferences")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Invisible balance spacer
                Color.clear
                    .frame(width: 50, height: 1)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
            // Preferences Content Card
            VStack(alignment: .leading, spacing: 12) {
                // Launch at Login Toggle
                Toggle(isOn: $launchManager.isEnabled) {
                    HStack {
                        Image(systemName: "bolt.badge.automatic")
                            .foregroundColor(Color(nsColor: .controlAccentColor))
                            .frame(width: 18)
                        Text("Start at Login")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                
                // Smart Battery Eco Mode
                if batteryMonitor.hasBattery {
                    Divider()
                        .opacity(0.3)
                    
                    Toggle(isOn: $manager.autoBatteryEcoEnabled) {
                        HStack {
                            Image(systemName: "battery.50")
                                .foregroundColor(.green)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Auto 60Hz on Battery")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Saves MacBook battery automatically")
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                    .controlSize(.small)
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
            
            // Keyboard Shortcuts Card
            VStack(alignment: .leading, spacing: 8) {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 6) {
                    HStack {
                        Text("⌥ ⇧ R")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(nsColor: .quaternaryLabelColor).opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Toggle Refresh Rate (60Hz ⟷ Max)")
                            .font(.system(size: 10.5))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("⌥ ⇧ ↑/↓")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(nsColor: .quaternaryLabelColor).opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Adjust Brightness (±10%)")
                            .font(.system(size: 10.5))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
            .padding(.horizontal, 14)
            
            Divider()
                .opacity(0.4)
                .padding(.horizontal, 10)
            
            // Done Button
            Button(action: {
                showingSettings = false
            }) {
                Text("Done")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color(nsColor: .controlAccentColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
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
