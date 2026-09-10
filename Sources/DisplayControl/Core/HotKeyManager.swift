import AppKit
import CoreGraphics

public final class HotKeyManager {
    public static let shared = HotKeyManager()
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    private init() {
        setupMonitors()
    }
    
    private func setupMonitors() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // consume event
            }
            return event
        }
    }
    
    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isOptionShift = flags == [.option, .shift]
        
        guard isOptionShift else { return false }
        
        switch event.keyCode {
        case 15: // 'R' key -> Toggle Refresh Rate
            DispatchQueue.main.async {
                DisplayManager.shared.toggleRefreshRate()
            }
            return true
            
        case 11: // 'B' key -> Toggle Blackout
            DispatchQueue.main.async {
                DisplayManager.shared.toggleBlackoutForAll()
            }
            return true
            
        case 126: // Up Arrow -> Brightness Up
            DispatchQueue.main.async {
                DisplayManager.shared.adjustBrightness(delta: 0.10)
            }
            return true
            
        case 125: // Down Arrow -> Brightness Down
            DispatchQueue.main.async {
                DisplayManager.shared.adjustBrightness(delta: -0.10)
            }
            return true
            
        default:
            return false
        }
    }
}
