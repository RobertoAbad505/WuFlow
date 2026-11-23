//
//  ObservationImageViewer.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/23/26.
//
import SwiftUI

struct ObservationImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    let observation: ObservationRecord

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()

                ActivityImageView(
                    path: observation.imagePath,
                    icon: observation.activity.iconName,
                    contentMode: .fill
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .padding(.top)
                VStack(alignment: .leading) {
                    dismissButton
                    Spacer()
                    data
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(.black)
        .preferredColorScheme(.dark)
    }
    
    var data: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(observation.note)
                .font(.system(size: 10).bold())
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(observation.date, style: .date)
                    .font(.system(size: 10))
                Spacer()
                if observation.kind == .incident {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("This was an incident")
                    }
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
                }
            }
        }
        .padding(10)
        .background(.regularMaterial)
    }
    
    var dismissButton: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.55), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close photo")
            .padding(20)
        }
    }
}
