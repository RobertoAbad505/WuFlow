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
    
    @State private var note: String = ""
    @State private var emotion: String = "🙂"
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
    
    private var backgroundStyle: BackgroundStyle {
        switch activity.type {
        case .increase: return .growth
        case .maintain: return .flow
        case .decrease: return .reduce
        }
    }
    private let emotionOptions = ["🙂", "😌", "😄", "😊", "😐", "🤔", "😕", "😔", "😣", "😤", "😰","🫠"]
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: self.backgroundStyle)
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
        VStack(spacing: 12) {
            closeHeader
            stepView
            navigationControls
        }
        .padding(16)
        .background(AppColors.surface.opacity(0.94), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppColors.divider.opacity(0.85), lineWidth: 1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    var stepView: some View {
        VStack(alignment: .center, spacing: 0) {
            switch step {
            case .note:
                noteSection
            case .image:
                imageSection
            case .incidentCheck:
                isAnIncidentSection
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
    
    private var incidentLabel: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 17))
            Text("This was an incident")
                .font(.headline)
                .fontWeight(.regular)
        }
        .foregroundStyle(.primary)
    }
    private var titleHeader: some View {
        HStack {
            Text("What did you observed about \(activity.name.lowercased())?")
                .font(.headline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
    }
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 18) {
            ZStack {
                if note.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Today I noticed ...")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary.opacity(0.6))
                            .padding(.horizontal, 8)
                    }
                }
                TextEditor(text: $note)
                    .frame(height: 140)
                    .textEditorStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(8)
            }
            .background(AppColors.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text("How did you feel?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.midnightNavy)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                    ForEach(emotionOptions, id: \.self) { option in
                        Button {
                            emotion = option
                        } label: {
                            Text(option)
                                .font(.system(size: 26))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    emotion == option ? AppColors.mistBlue : AppColors.canvas,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(emotion == option ? AppColors.oceanBlue : .clear, lineWidth: 1.5)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Select \(option)")
                    }
                }
            }
        }
    }
    private var closeHeader: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }, label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            })
            .foregroundStyle(AppColors.midnightNavy)
            .background(AppColors.mistBlue.opacity(0.55), in: Capsule())
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private var visualInputSection: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Do you have a picture or image about it?")
                .font(.headline)
                .fontWeight(.medium)
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
                .tint(AppColors.midnightNavy)
                
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
               .tint(AppColors.oceanBlue)
            }
            .padding(10)
            Spacer()
        }
    }
    private var isAnIncidentSection: some View {
        VStack {
            Text("Was this an incident?")
                .font(.headline)
                .fontWeight(.medium)
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
                .foregroundStyle(isAnIncident ? AppColors.vermilion : AppColors.secondaryText)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isAnIncident ? AppColors.vermilion.opacity(0.12) : AppColors.canvas)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isAnIncident ? AppColors.vermilion.opacity(0.5) : AppColors.divider, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }
    var reviewSection: some View {
        VStack(spacing: 17) {
            Text("Got it, is this correct?")
                .font(.headline)
                .fontWeight(.medium)
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
        .foregroundStyle(AppColors.midnightNavy)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20,
                                     style: .continuous).fill(AppColors.surface))
    }
    private var actions: some View {
        Button(action: {
            dismiss()
        }, label: {
            Label("Cancel", systemImage: "xmark")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 3)
        })
        .buttonStyle(.bordered)
        .tint(AppColors.secondaryText)
    }
    private var preview: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 250)
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
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .foregroundStyle(AppColors.midnightNavy)
                .background(AppColors.mistBlue.opacity(0.55), in: Capsule())
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
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .foregroundStyle(AppColors.surface)
            .background(AppColors.midnightNavy, in: Capsule())
        }
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
                                       goalValue: 2),
                       cameraManager: .init(),
                       onDismiss: { new in
        print("dismissed")
        print("\(new?.note ?? "no note")")
    })
}
