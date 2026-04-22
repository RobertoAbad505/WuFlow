//
//  CreateActivityView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct CreateActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var cameraManager: CameraManager = CameraManager()
    
    //new activity properties
    @State private var name: String = ""
    @State private var motivationDescription: String = ""
    @State private var newUnitType: UnitType = .count
    @State private var newGoalValue: Double = 0
    @State private var newTrackingType: TrackingType = .manual
    
    var body: some View  {
        ScrollView {
            content
        }
    }
    
    var content: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Create activity")
                .font(Font.largeTitle.bold())
                .padding(.bottom, 20)
            
            //Name input
            TextField("Name", text: $name, prompt: Text("Activity name?"))
                .textContentType(UITextContentType.name)
                .font(Font.body.bold())
            
            //Unit type input
            Picker("Unit type", selection: $newUnitType) {
                ForEach(UnitType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.palette)
            
            //Goal input
            TextField("Goal value", value: $newGoalValue, formatter: NumberFormatter(), prompt: Text("Goal value?"))
                .textContentType(UITextContentType.name)
                .font(Font.body.bold())
            
            //Tracking type input
            Picker("Tracking type", selection: $newTrackingType) {
                ForEach(TrackingType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.palette)
            
            Button(action: {
                //TAKE A PICTURe
                cameraManager.checkCameraPermission(completion: { cameraPermisison in
                    if cameraPermisison {
                        cameraManager.openCamera()
                    }
                })
                
            }, label: {
                HStack {
                    Image(systemName: "camera.fill")
//                        .resizable()
                        .frame(width: 20, height: 20)
                    Text(cameraManager.image == nil ? "Take a picture!":"Retake picture!")
                }
                .foregroundStyle(Color.white)
            })
            .padding()
            .background(Color.blue)
            .cornerRadius(15)
            
            TextField(text: $motivationDescription, label: {
                Text("What motivates you for this?")
            })
            
            if let image = cameraManager.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            }
            
            Button("Create") {
                addItem()
                dismiss()
            }
            .padding(.top, 50)
        }
        .padding()
        .sheet(isPresented: $cameraManager.showImagePicker) {
            ImagePicker(image: $cameraManager.image, isPresented: $cameraManager.showImagePicker)
        }
    }
    
    private func addItem() {
        withAnimation {
            
            let imageData = cameraManager.image?.jpegData(compressionQuality: 0.8)
            let newItem = Activity(
                name: name,
                unitType: newUnitType,
                goalValue: newGoalValue,
                trackingType: newTrackingType,
                iconName: "circle.dotted",
                motivationDescription: motivationDescription,
                expectedOutcome: "",                
                imageData: imageData
            )
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    CreateActivityView()
        .modelContainer(for: Activity.self, inMemory: false)
}
