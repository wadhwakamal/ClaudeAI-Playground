import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Claude AI Demo App")
                    .font(.title)
                    .padding()
                
                Text("This is a fallback content view")
                    .padding()
                
                // Navigate to the LoginView
                NavigationLink(destination: LoginView()) {
                    Text("Go to Login")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                // Show items from SwiftData
                List {
                    ForEach(items) { item in
                        Text("Item at \(item.timestamp, format: .dateTime)")
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addItem() {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
