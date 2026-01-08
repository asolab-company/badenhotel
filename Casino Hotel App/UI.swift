import Foundation
import SwiftUI

enum Device {
    static var isSmall: Bool {
        UIScreen.main.bounds.height < 700
    }

    static var isMedium: Bool {
        UIScreen.main.bounds.height >= 700 && UIScreen.main.bounds.height < 850
    }

    static var isLarge: Bool {
        UIScreen.main.bounds.height >= 850
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct BtnStyle: ButtonStyle {
    var height: CGFloat = 50
    var width: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        let baseGradient = LinearGradient(
            colors: [
                Color(hex: "#FFA600"),
                Color(hex: "#FFA600"),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        return configuration.label
            .frame(
                maxWidth: width ?? .infinity,
                maxHeight: height
            )
            .frame(width: width)
            .frame(height: height)
            .background(
                baseGradient
                    .clipShape(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
