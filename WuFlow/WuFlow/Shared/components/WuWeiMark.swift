import SwiftUI

struct WuWeiMark: View {
    let size: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let diameter = geometry.size.width
            ZStack {
                Circle()
                    .fill(AppColors.surface)
                YinYangDarkHalf()
                    .fill(AppColors.midnightNavy)
                Circle()
                    .fill(AppColors.surface)
                    .frame(width: diameter * 0.2, height: diameter * 0.2)
                    .position(x: diameter * 0.29, y: diameter * 0.25)
                Circle()
                    .fill(AppColors.midnightNavy)
                    .frame(width: diameter * 0.2, height: diameter * 0.2)
                    .position(x: diameter * 0.71, y: diameter * 0.75)
            }
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(AppColors.midnightNavy.opacity(0.25), lineWidth: 0.5)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct YinYangDarkHalf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.minX + rect.width * 1.2, y: rect.minY + rect.height * 0.2),
            control2: CGPoint(x: rect.minX - rect.width * 0.2, y: rect.minY + rect.height * 0.8)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
