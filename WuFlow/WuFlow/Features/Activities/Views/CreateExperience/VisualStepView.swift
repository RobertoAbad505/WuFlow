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
            if let image = newImage {
                draft.imageData = image.jpegData(compressionQuality: 0.8)
            }
        }
    }
    private var preview: some View {
        ZStack {
            
            if let data = draft.imageData,
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                
            } else {
                
                Image(systemName: draft.iconName)
                    .font(.system(size: 60))
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
                    draft.imageData == nil ? "Take a picture" : "Retake picture",
                    systemImage: "camera.fill"
                )
            }
            .buttonStyle(.borderedProminent)
            
            if draft.imageData != nil {
                Button("Remove image") {
                    draft.imageData = nil
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
