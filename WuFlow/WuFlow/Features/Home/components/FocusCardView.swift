//
//  FocusCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/23/26.
//
import SwiftUI

struct FocusCardView: View {

    let item: ActivitySummary
    let action: () -> Void

    var body: some View {

        Button(action: action) {
            ZStack {
                activityImage
                VStack {
                    Spacer()
                    VStack {
                        Text(item.activity.name)
                            .font(.system(size: 11, weight: .bold))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .lineLimit(5)
                            .foregroundStyle(.black)
                        Text(progressDescription)
                            .font(.caption)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.gray)
                        ProgressView(value: item.progress.ratio)
                            .tint(progressColor)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(.white.opacity(0.6))
                }
            }
            .frame(minWidth: 120)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .overlay {
            if item.progress.status == .exceeded {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 2)
                    .fill(progressColor)
                    .shadow(color: .yellow,
                            radius: 20,
                            x: 5,
                            y: -5
                    )
            }
        }
    }
    var activityImage: some View {
        ActivityImageView(path: item.activity.imagePath, icon: item.activity.iconName)
            .scaledToFill()
            .frame(maxWidth: 150, maxHeight: 180)
    }
}

private extension FocusCardView {
    var progressDescription: String {
        "\(Int(item.progress.value)) / \(Int(item.progress.goal)) \(item.activity.measurement.displayName)"
    }
    var progressColor: Color {
        switch item.progress.status {
        case .exceeded:
            return .yellow
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .notStarted:
            return .gray
        }
    }
}

#Preview {
//    let path = try? ImageStore.shared.save(UIImage(named: "selfie") ?? UIImage(), category: .activity)
    var preview = ActivitySummary.preview
//    preview.activity.imagePath = path
    VStack {
        HStack {
            FocusCardView(item: preview, action: { })
            FocusCardView(item: preview, action: { })
            FocusCardView(item: preview, action: { })
        }
    }
    .padding()
}
