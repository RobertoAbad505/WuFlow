//
//  VisualStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct VisualStepView: View {
    
    @Binding var draft: ActivityDraft
    @ObservedObject var cameraManager: CameraManager
    
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
            guard let newImage else { return }
            let path = try? ImageStore.shared.save(
                newImage,
                category: .activity,
                maxDimension: 1024,
                compression: 0.6
            )

            draft.imagePath = path
        }
    }
    private var preview: some View {
        ZStack {
            
            if let uiImage = cameraManager.image {
                Image(uiImage: uiImage)
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
            }
            .buttonStyle(.borderedProminent)
            
            if draft.imagePath != nil {
                Button("Remove image") {
                    draft.imagePath = nil
                    cameraManager.image = nil
                }
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    VisualStepView(draft: .constant(ActivityDraft()), cameraManager: .init())
}
