//
//  ActivityImageView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/4/26.
//
import SwiftUI

struct ActivityImageView: View {
    
    let path: String?
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
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
        Image(systemName: "circle.dotted")
            .font(.system(size: 30))
            .foregroundColor(.secondary)
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let loaded = ImageStore.shared.load(from: path)
            
            DispatchQueue.main.async {
                self.image = loaded
            }
        }
    }
}
