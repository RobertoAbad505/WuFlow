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
    
    @State private var image: UIImage?
    
    init(path: String?, icon: String?, category: ImageCategory = .activity) {
        self.path = path
        self.category = category
        self.icon = icon
    }
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    var placeholder: some View {
        Image(systemName: icon ?? "circle.dotted")
            .symbolEffect(.breathe.byLayer)
            .font(.system(size: 30))
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
