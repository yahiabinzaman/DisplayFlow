import Foundation
import CoreGraphics

public final class DisplayBrightnessBridge {
    public static let shared = DisplayBrightnessBridge()
    
    private typealias DisplayServicesGetBrightnessFunc = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
    private typealias DisplayServicesSetBrightnessFunc = @convention(c) (CGDirectDisplayID, Float) -> Int32
    
    private var getBrightnessFunc: DisplayServicesGetBrightnessFunc?
    private var setBrightnessFunc: DisplayServicesSetBrightnessFunc?
    
    private init() {
        if let handle = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_LAZY) {
            if let symGet = dlsym(handle, "DisplayServicesGetBrightness") {
                getBrightnessFunc = unsafeBitCast(symGet, to: DisplayServicesGetBrightnessFunc.self)
            }
            if let symSet = dlsym(handle, "DisplayServicesSetBrightness") {
                setBrightnessFunc = unsafeBitCast(symSet, to: DisplayServicesSetBrightnessFunc.self)
            }
        }
    }
    
    public func getHardwareBrightness(displayID: CGDirectDisplayID) -> Float? {
        guard let getBrightnessFunc = getBrightnessFunc else { return nil }
        var brightness: Float = 0.0
        let result = getBrightnessFunc(displayID, &brightness)
        if result == 0 {
            return max(0.0, min(1.0, brightness))
        }
        return nil
    }
    
    public func setHardwareBrightness(displayID: CGDirectDisplayID, brightness: Float) -> Bool {
        guard let setBrightnessFunc = setBrightnessFunc else { return false }
        let clamped = max(0.0, min(1.0, brightness))
        let result = setBrightnessFunc(displayID, clamped)
        return result == 0
    }
}
