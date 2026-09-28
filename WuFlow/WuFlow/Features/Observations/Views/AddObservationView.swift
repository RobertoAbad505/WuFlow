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
    @State var emotion: String = ""
    @ObservedObject var cameraManager: CameraManager = .init()
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isAnIncident: Bool = false
    @State private var selectedImage: UIImage?
    @State private var imageSource: ImageSource = .defaultImage
    
    @State private var imagePath: String?
    
    var image: UIImage? {
        ImageStore.shared.load(from: imagePath, category: .activity)
    }
    
    //FLOW STEPS
    var steps: [CreateObservationStep] {
        ObservationFlow.steps()
    }
    @State private var step: CreateObservationStep = .note
    
    let onDismiss: ((ObservationRecord?) -> Void)
    
    var body: some View {
        
        ZStack {
            AnimatedBackgroundView(style: .night)
                .ignoresSafeArea()
            content
        }
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
        VStack(alignment: .leading){
            stepView
            navigationControls
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    var stepView: some View {
        VStack(alignment: .center, spacing: 0) {
            closeHeader
            switch step {
            case .note:
                noteSection
            case .image:
                imageSection
            case .incidentCheck:
                incidentCheck
            case .review:
                reviewSection
            }
        }
    }

    var noteSection: some View {
        VStack {
            titleHeader
            textInputView
        }
    }
    var imageSection: some View {
        VStack {
            visualInputSection
        }
    }
    
    var incidentCheck: some View {
        VStack {
            isAnIncidentSection
        }
    }
    
    var reviewSection: some View {
        VStack {
            Text("Got it, is this correct?")
                .font(.title2)
            summaryCard
        }
    }
    private var summaryCard: some View {
        VStack(spacing: 20) {
            preview
            Divider()
            Text(note)
                .font(.body)
            Divider()
            Text(emotion)
                .font(.body)
            if isAnIncident {
                Divider()
                incidentLabel
            }
            actions
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
    }
    private var incidentLabel: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.title3)
            Text("This was an incident")
                .font(.headline)
        }
        .foregroundStyle(.primary)
    }
    private var isAnIncidentSection: some View {
        VStack {
            
            Text("Do you think is an incident?")
                .font(.title2)
            Button {
                isAnIncident.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName:
                        isAnIncident
                        ? "checkmark.circle.fill"
                        : "circle"
                    )
                    .font(.title3)

                    Text("This was an incident")

                    Spacer()
                }
                .foregroundStyle(isAnIncident ? .primary : .secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isAnIncident ? .orange.opacity(0.12) : .clear)
                )
            }
            .buttonStyle(.plain)
        }
    }
    private var titleHeader: some View {
        HStack {
            Text("Describe your observation for \(activity.name)?👀")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
    }
    private var closeHeader: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }, label: {
                HStack {Image(systemName: "chevron.left")}
                .font(.system(size: 15, weight: .regular))
            })
            .buttonStyle(.glass)
        }
        .padding()
        .foregroundStyle(Color(.label))
    }
    private var textInputView: some View {
        VStack {
            ZStack {
                if note.isEmpty {
                    Text("I want to feel more focused, calm, and in control...")
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.horizontal, 8)
                }
                TextEditor(text: $note)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 120)
                    .textEditorStyle(.plain)
                    .offset(y: 20)
            }
            VStack(alignment: .leading) {
                Text("Pick an emoji that best describes how you felt")
                TextField("🙂", text: $emotion)
                    .font(.system(size: 32))
                    .multilineTextAlignment(.center)
                    .onChange(of: emotion) { _, newValue in
                        if let first = newValue.first {
                            emotion = String(first)
                        }
                    }
            }
        }
    }
    private var visualInputSection: some View {
        VStack {
            Text("Want to add a photo?")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            preview
            VStack(spacing: 10) {
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
            .padding(10)
        }
    }
    private var actions: some View {
        Button(action: {
            dismiss()
        }, label: {
            Image(systemName: "clear")
                .font(.system(size: 15))
            Text("Cancel")
        })
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 25))
    }
    private var preview: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .symbolEffect(.pulse)
            }
        }
        .id("id\(self.imagePath ?? "")")
    }
    
    func save() {
        let newObservation = ObservationRecord(
            date: .now,
            note: note,
            emotion: emotion,
            imagePath: self.imagePath,
            activity: self.activity,
            kind: self.isAnIncident ? .incident : .note
        )
        onDismiss(newObservation)
        dismiss()
    }
    //🥺
}
extension AddObservationView {
    
    var navigationControls: some View {
        HStack(alignment: .top, spacing: 0) {
            if step != .note {
                Button(action: {
                    withAnimation {
                        step = previousStep()
                    }
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(Font.body)
                        Text("Back")
                    }
                })
                .padding()
                .glassEffect()
            }
            Spacer()
            Button(action: {
                handleNext()
            }, label: {
                HStack {
                    Text(step == .review ? modeTitle : "Next")
                    Image(systemName: step == .review ? "plus":"chevron.right")
                        .font(Font.body)
                }
            })
            .padding()
            .glassEffect()
        }
        .tint(.green)
        .padding()
        .font(.body)
    }
    var modeTitle: String {
        "Save observation"
    }
    func nextStep() -> CreateObservationStep {
        let steps = steps
        guard let index = steps.firstIndex(of: step),
              index < steps.count - 1 else {
            return step
        }
        return steps[index + 1]
    }

    func previousStep() -> CreateObservationStep {
        let steps = steps
        guard let index = steps.firstIndex(of: step),
              index > 0 else {
            return step
        }
        return steps[index - 1]
    }
    func handleNext() {
        if step == .review {
            save()
            withAnimation {
                dismiss()
            }
        } else {
            withAnimation {
                step = nextStep()
            }
        }
    }
}
enum CreateObservationStep {
    case note
    case image
    case incidentCheck
    case review
}
struct ObservationFlow {

    static func steps() -> [CreateObservationStep] {
        return defaultSteps
    }

    static let defaultSteps: [CreateObservationStep] = [
        .note,
        .image,
        .incidentCheck,
        .review
    ]
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
//🤖🤖
