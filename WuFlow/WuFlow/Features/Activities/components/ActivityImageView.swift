//
//  ActivityImageView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/4/26.
//
import SwiftUI

struct ActivityImageView: View {
    
    let path: String?
    let icon: String?
    let category: ImageCategory
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    
    init(
        path: String?,
        icon: String?,
        category: ImageCategory = .activity,
        contentMode: ContentMode = .fill
    ) {
        self.path = path
        self.category = category
        self.icon = icon
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            loadImage()
        }
    }
    
    var placeholder: some View {
        Image(systemName: icon ?? "circle.dotted")
            .symbolEffect(.breathe.byLayer)
            .font(.system(size: 35))
            .foregroundColor(.secondary)
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let loaded = ImageStore.shared.load(from: path, category: self.category) {
                DispatchQueue.main.async {
                    self.image = loaded
                }
            }
        }
    }
}
