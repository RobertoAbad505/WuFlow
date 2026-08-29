//
//  PlacesListView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/28/26.
//

import SwiftUI
import SwiftData

struct PlacesListView: View {
    @Environment(\.repository) private var repository
    @Query()
    private var places: [Place]
    private let columns = [
        GridItem(.flexible())
    ]
    
    //ON DELETE
    @State var showDeleteAlert = false
    @State private var selectedToDelete: Place?
    @State private var showDeleteDialog = false
    
    //ON CREATE
    @State private var onCreatePlace: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                AnimatedBackgroundView(style: .focus)
                content
            }
        }
        .navigationDestination(for: Place.self) { selectedItem in
            PlaceDetailsView(selectedItem)
        }
        .fullScreenCover(isPresented: $onCreatePlace, content: {
            AddPlaceView()
        })
    }
    
    var content: some View {
        VStack {
            ScrollView {
                header
                gridView
            }
        }
    }
    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("📍My Places")
                    .font(.title)
                Text("Select a place to see more details")
                    .font(.subheadline)
                    .padding(.leading, 10)
            }
            Spacer()
        }
        .padding()
    }
    
    var gridView: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(places) { place in
                    NavigationLink(value: place) {
                        PlaceCardView(place)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedToDelete = place
                            showDeleteDialog = true
                            print("Place selected to delete: \(place.name)")
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                addNewPlaceBtn
            }
        }
        .padding(.horizontal)
        .confirmationDialog(
            "Delete Place?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                delete(selectedToDelete)
            }
            Button("Cancel", role: .cancel) {
                selectedToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    var addNewPlaceBtn: some View {
        Button(action: addItem) {
            VStack(spacing: 20) {
                Text("Add a new place!")
                Image(systemName: "plus")
            }
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
            .padding()
            .frame(width: 200, height: 200)
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 2)
        }
        .padding(.bottom)
    }
    
    private func addItem() {
        withAnimation {
            onCreatePlace.toggle()
        }
    }
    
    private func delete(_ place: Place?) {
        Task {
            guard let repository, let selectedToDelete else { return }
            do {
                try await repository.deletePlace(id: selectedToDelete.persistentModelID)
            } catch let error {
                print("❌ Delete place failed:", error)
                print("place name: \(selectedToDelete.name)")
                print("error.localizedDescription:", error)
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}


#Preview("Places List") {
    // Seed initial data into an in-memory model container so @Query works in previews
    let previewItems = [
        Place(identifier: "123", name: "Iron gym", latitude: 123456, longitude: 123456),
        Place(identifier: "456", name: "Kaomi's house", latitude: 123456, longitude: 123456),
        Place(identifier: "789", name: "Cimatario", latitude: 123456, longitude: 123456),
        Place(identifier: "101", name: "Centro historico", latitude: 123456, longitude: 123456)
    ]
    NavigationStack {
        PlacesListView()
            .modelContainer(for: Place.self, inMemory: true) { result in
                if case let .success(container) = result {
                    let context = container.mainContext
                    previewItems.forEach { context.insert($0) }
                    try? context.save()
                }
            }
    }
}
