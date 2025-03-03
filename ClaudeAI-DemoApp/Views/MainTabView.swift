import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                // Home tab content
                Text("Home Screen")
                    .navigationTitle("Home")
                    .toolbar {
                        Button("Logout") {
                            Task {
                                await authViewModel.logout()
                            }
                        }
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationStack {
                // Profile tab content
                ProfileView(userId: "sample", preloadedUser: User.sample)
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
