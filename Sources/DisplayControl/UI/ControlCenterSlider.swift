import SwiftUI
import AppKit

public struct ControlCenterSlider: View {
    @Binding var value: Double // 0.0 to 1.0
    var iconName: String = "sun.max.fill"
    var onEditingChanged: ((Bool) -> Void)? = nil
    
    @State private var isDragging: Bool = false
    
    public init(
        value: Binding<Double>,
        iconName: String = "sun.max.fill",
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.iconName = iconName
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let progress = max(0.0, min(1.0, CGFloat(value)))
            let fillWidth = max(height, width * progress)
            
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.3))
                
                // Active Fill
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(Color.white)
                    .frame(width: fillWidth, height: height)
                    .shadow(color: Color.black.opacity(0.12), radius: 2, x: 1, y: 1)
                
                // Embedded Icon on Left
                HStack {
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(progress > 0.12 ? Color.black.opacity(0.75) : Color(nsColor: .secondaryLabelColor))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    // Percentage on the right (fades in cleanly)
                    Text("\(Int(value * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(progress > 0.88 ? Color.black.opacity(0.75) : Color.white.opacity(0.85))
                        .padding(.trailing, 12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        let newProgress = max(0.02, min(1.0, gesture.location.x / width))
                        value = Double(newProgress)
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged?(false)
                    }
            )
        }
        .frame(height: 30)
    }
}
