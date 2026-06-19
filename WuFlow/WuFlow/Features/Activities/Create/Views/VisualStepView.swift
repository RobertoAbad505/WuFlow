//
//  VisualStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI
import PhotosUI

struct VisualStepView: View {
    
    @Binding var draft: ActivityDraft
    @ObservedObject var cameraManager: CameraManager
    
    @State private var selectedPhoto: PhotosPickerItem?

    @State private var selectedImage: UIImage?
    @State private var imageSource: ImageSource = .defaultImage
    var image: UIImage? {
        ImageStore.shared.load(from: draft.imagePath, category: .activity)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Give it a visual identity")
                .font(.title2)
            
            Text("This helps you recognize your activity instantly")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            preview
            
            actions
            
        }
        .padding()
        .fullScreenCover(isPresented: $cameraManager.showImagePicker) {
            ImagePicker(
                image: $cameraManager.image,
                isPresented: $cameraManager.showImagePicker
            )
        }
        .onChange(of: cameraManager.image) { newImage in
            guard let newImage else {
                print("New image is null!!!")
                return
            }
            imageSource = .camera
            let path = try? ImageStore.shared.save(
                newImage,
                category: .activity,
                maxDimension: 1024,
                compression: 0.6
            )

            draft.imagePath = path
        }
        .onChange(of: selectedPhoto) { _, newImage in
            
            guard let newImage else { return }

            Task {
                do {
                    if let data = try await newImage.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        
                        selectedImage = image

                        // Reuse your existing save logic here
                        let path = try? ImageStore.shared.save(
                            image,
                            category: .activity,
                            maxDimension: 1024,
                            compression: 0.6
                        )
                        imageSource = .library
                        draft.imagePath = path
                    }

                } catch {
                    print("❌ Failed loading image:", error)
                }
            }
        }
    }
    private var preview: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Image(systemName: draft.iconName)
                    .font(.system(size: 70))
                    .foregroundColor(.secondary)
                    .frame(width: 180, height: 180)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .symbolEffect(.pulse, value: draft.iconName)
            }
        }
        .id("id\(draft.imagePath)")
    }
    private var actions: some View {
        VStack(spacing: 16) {
            
            Button {
                cameraManager.checkCameraPermission { granted in
                    if granted {
                        cameraManager.openCamera()
                    }
                }
            } label: {
                Label(
                    draft.imagePath == nil ? "Take a picture" : "Retake picture",
                    systemImage: "camera.fill"
                )
                .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "photo")
                    Text("Choose from Library")
                }
                .frame(maxWidth: 200)
            }
            .buttonStyle(.bordered)
            
            if draft.imagePath != nil {
                Button("Remove image") {
                    ImageStore.shared.delete(at: draft.imagePath)
                    draft.imagePath = nil
                    cameraManager.image = nil
                }
                .foregroundColor(.red)
            }
        }
    }
}
enum ImageSource {
    case library
    case icon
    case camera
    case defaultImage
}

#Preview {
    VisualStepView(draft: .constant(ActivityDraft()), cameraManager: .init())
}
