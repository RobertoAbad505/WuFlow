//
//  ActivityListView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct ActivityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Activity]

    @State var toggleCreateActivity: Bool = false
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        Text(item.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .sheet(isPresented: $toggleCreateActivity, content: {
                CreateActivityView(onDismiss: {
                    withAnimation {
                        self.toggleCreateActivity = false
                    }
                })
            })
            .navigationDestination(for: Activity.self) { selectedItem in
                ActivityDetailView(activity: selectedItem)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
//            deleteAllData()
        }
        
    }
    func deleteAllData() {
        let activities = try? modelContext.fetch(FetchDescriptor<Activity>())
        let records = try? modelContext.fetch(FetchDescriptor<ProgressRecord>())
        
        activities?.forEach { modelContext.delete($0) }
        records?.forEach { modelContext.delete($0) }
    }

    private func addItem() {
        withAnimation {
            toggleCreateActivity.toggle()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}


#Preview {
    ActivityListView()
        .modelContainer(for: Activity.self, inMemory: true)
}
