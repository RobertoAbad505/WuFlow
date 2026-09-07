//
//  AddObservationView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/6/26.
//

import SwiftUI
import PhotosUI

struct AddObservationView: View {
    
    @Environment(\.dismiss) var dismiss
    let activity: Activity
    
    @State var note: String = ""
    @State var emotion: String = "🫠"
    @ObservedObject var cameraManager: CameraManager = .init()
    
    @State private var selectedPhoto: PhotosPickerItem?

    @State private var selectedImage: UIImage?
    @State private var imageSource: ImageSource = .defaultImage
    
    @State private var imagePath: String?
    
    var image: UIImage? {
        ImageStore.shared.load(from: imagePath, category: .activity)
    }
    
    let onDismiss: ((ObservationRecord?) -> Void)
    
    var body: some View {
        VStack(alignment: .leading){
            content
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .background(.ultraThinMaterial)
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

            imagePath = path
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
                        self.imagePath = path
                    }

                } catch {
                    print("❌ Failed loading image:", error)
                }
            }
        }
    }
    var content: some View {
        VStack {
            titleHeader
            textInputView
            preview
            actions
        }
    }
    private var titleHeader: some View {
        VStack {
            Text("What is your observation for \(activity.name)?\n👀")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    private var textInputView: some View {
        VStack {
            ZStack {
                if note.isEmpty {
                    Text("I want to feel more focused, calm, and in control...")
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.top, 12)
                }
                TextEditor(text: $note)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 120)
                    .textEditorStyle(.plain)
            }
            TextField("Emotion", text: $emotion, prompt: Text("Pick an emoji for this feeling"))
        }
    }
    private var actions: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    cameraManager.checkCameraPermission { granted in
                        if granted {
                            cameraManager.openCamera()
                        }
                    }
                } label: {
                    Label(
                        self.imagePath == nil ? "Take a picture" : "Retake picture",
                        systemImage: "camera.fill"
                    )
                    .font(.system(size: 15))
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
                    .font(.system(size: 15))
                    .frame(maxWidth: 200)
                }
               .buttonStyle(.bordered)
            }
            if self.imagePath != nil {
                Button("Remove image") {
                    ImageStore.shared.delete(at: self.imagePath)
                    self.imagePath = nil
                    cameraManager.image = nil
                }
                .foregroundColor(.red)
            }
            Button(action: {
                save()
            }, label: {
                Text("Add Observation")
                Image(systemName: "plus")
            })
            .frame(maxWidth: .infinity, maxHeight: 40)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 25))
            
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "clear")
                    .font(.system(size: 15))
                Text("Cancel")
            })
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 40)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 25))
        }
        
    }
    private var preview: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: 150)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .symbolEffect(.pulse)
            }
        }
        .id("id\(self.imagePath)")
    }
    
    func save() {
        let newObservation = ObservationRecord(
            date: .now,
            note: note,
            emotion: emotion,
            imagePath: self.imagePath,
            activity: self.activity
        )
        onDismiss(newObservation)
        dismiss()
    }
}

#Preview {
    
    AddObservationView(activity: .init(name: "Gym",
                                       unitType: .count,
                                       goalValue: 2), cameraManager: .init(), onDismiss: { new in
        print("dismissed")
        print("\(new?.note ?? "no note")")
    }
    )
}
