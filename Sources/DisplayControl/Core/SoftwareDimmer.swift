import AppKit
import CoreGraphics

public final class SoftwareDimmer {
    public static let shared = SoftwareDimmer()
    
    private var overlayWindows: [CGDirectDisplayID: NSWindow] = [:]
    private var dimLevels: [CGDirectDisplayID: Float] = [:]
    private var warmthLevels: [CGDirectDisplayID: Float] = [:]
    private var blackoutStates: [CGDirectDisplayID: Bool] = [:]
    
    private init() {}
    
    public func setDimming(for displayID: CGDirectDisplayID, brightness: Float) {
        dimLevels[displayID] = max(0.0, min(1.0, brightness))
        updateOverlay(for: displayID)
    }
    
    public func setWarmth(for displayID: CGDirectDisplayID, warmth: Float) {
        warmthLevels[displayID] = max(0.0, min(1.0, warmth))
        updateOverlay(for: displayID)
    }
    
    public func setBlackout(for displayID: CGDirectDisplayID, isBlackedOut: Bool) {
        blackoutStates[displayID] = isBlackedOut
        updateOverlay(for: displayID)
    }
    
    private func updateOverlay(for displayID: CGDirectDisplayID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let isBlackout = self.blackoutStates[displayID] ?? false
            let brightness = self.dimLevels[displayID] ?? 1.0
            let warmth = self.warmthLevels[displayID] ?? 0.0
            
            let needsOverlay = isBlackout || brightness < 0.99 || warmth > 0.01
            
            if !needsOverlay {
                self.overlayWindows[displayID]?.orderOut(nil)
                self.overlayWindows.removeValue(forKey: displayID)
                return
            }
            
            let window = self.getOrCreateWindow(for: displayID)
            
            if isBlackout {
                window.backgroundColor = NSColor.black
            } else {
                // Combine warmth and dimming
                let dimAlpha = CGFloat(1.0 - brightness) * 0.90
                let warmthAlpha = CGFloat(warmth) * 0.35
                
                if warmth > 0.01 && brightness < 0.99 {
                    // Blend warm amber and dimming
                    window.backgroundColor = NSColor(
                        calibratedRed: 1.0,
                        green: 0.55,
                        blue: 0.10,
                        alpha: max(dimAlpha, warmthAlpha)
                    ).blended(withFraction: Double(dimAlpha), of: .black) ?? .black
                } else if warmth > 0.01 {
                    window.backgroundColor = NSColor(
                        calibratedRed: 1.0,
                        green: 0.58,
                        blue: 0.15,
                        alpha: warmthAlpha
                    )
                } else {
                    window.backgroundColor = NSColor.black.withAlphaComponent(dimAlpha)
                }
            }
            
            window.orderFrontRegardless()
        }
    }
    
    private func getOrCreateWindow(for displayID: CGDirectDisplayID) -> NSWindow {
        if let existing = overlayWindows[displayID] {
            updateWindowFrame(existing, displayID: displayID)
            return existing
        }
        
        let screen = NSScreen.screens.first { screen in
            (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) == displayID
        }
        let frame = screen?.frame ?? NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        
        let window = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        
        overlayWindows[displayID] = window
        return window
    }
    
    private func updateWindowFrame(_ window: NSWindow, displayID: CGDirectDisplayID) {
        if let screen = NSScreen.screens.first(where: {
            ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) == displayID
        }) {
            window.setFrame(screen.frame, display: true)
        }
    }
    
    public func clearAll() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindows.values.forEach { $0.orderOut(nil) }
            self?.overlayWindows.removeAll()
            self?.dimLevels.removeAll()
            self?.warmthLevels.removeAll()
            self?.blackoutStates.removeAll()
        }
    }
}
