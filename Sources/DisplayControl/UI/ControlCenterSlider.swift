import SwiftUI
import AppKit

public struct ControlCenterSlider: View {
    @Binding var value: Double // 0.0 to 1.0
    var iconName: String = "sun.max.fill"
    var activeColor: Color = .white
    var iconColor: Color? = nil
    var onEditingChanged: ((Bool) -> Void)? = nil
    
    @State private var isDragging: Bool = false
    
    public init(
        value: Binding<Double>,
        iconName: String = "sun.max.fill",
        activeColor: Color = .white,
        iconColor: Color? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.iconName = iconName
        self.activeColor = activeColor
        self.iconColor = iconColor
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let progress = max(0.0, min(1.0, CGFloat(value)))
            let fillWidth = width * progress
            
            ZStack(alignment: .leading) {
                // Background Track (macOS Control Center translucent dark track)
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.35))
                
                // Active Fill Bar
                if progress > 0.01 {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(activeColor)
                        .frame(width: max(height, fillWidth), height: height)
                }
                
                // Content Layer (Icon + Value)
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(
                            progress > 0.18
                            ? (activeColor == .white ? Color.black.opacity(0.8) : Color.white)
                            : (iconColor ?? Color(nsColor: .secondaryLabelColor))
                        )
                        .frame(width: height, height: height)
                    
                    Spacer()
                    
                    Text("\(Int(value * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(
                            progress > 0.82
                            ? (activeColor == .white ? Color.black.opacity(0.8) : Color.white)
                            : Color(nsColor: .secondaryLabelColor)
                        )
                        .padding(.trailing, 10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        let newProgress = max(0.0, min(1.0, gesture.location.x / width))
                        value = Double(newProgress)
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged?(false)
                    }
            )
        }
        .frame(height: 28)
    }
}
