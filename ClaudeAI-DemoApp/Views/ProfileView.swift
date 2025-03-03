import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserViewModel()
    let userId: String
    
    // For preview and direct initialization
    var preloadedUser: User?
    
    var body: some View {
        content
            .navigationTitle("Profile")
            .task {
                if preloadedUser == nil {
                    await viewModel.fetchUser(id: userId)
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let user = preloadedUser ?? viewModel.user {
            userProfileView(user: user)
        } else if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else {
            emptyView
        }
    }
    
    private func userProfileView(user: User) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile header with avatar
                HStack(spacing: 15) {
                    Image(systemName: user.profileImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(user.username)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Edit profile action
                        print("Edit profile tapped")
                    }) {
                        Text("Edit")
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 10)
                
                // Bio section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    
                    Text(user.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Stats section
                HStack(spacing: 0) {
                    StatItem(value: "\(user.postCount)", label: "Posts")
                    StatItem(value: "\(user.followerCount)", label: "Followers")
                    StatItem(value: "\(user.followingCount)", label: "Following")
                }
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Recent activity section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.headline)
                    
                    if user.recentActivities.isEmpty {
                        Text("No recent activity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 5)
                    } else {
                        ForEach(user.recentActivities) { activity in
                            ActivityRow(activity: activity)
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.fetchUser(id: userId)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading profile...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error loading profile")
                .font(.headline)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await viewModel.fetchUser(id: userId)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack {
            Text("No profile data available")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Helper components
struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(.blue)
            
            Text(activity.description)
                .font(.subheadline)
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Preview with preloaded sample user
            ProfileView(userId: "sample", preloadedUser: User.sample)
        }
        .previewDisplayName("Loaded State")
        
        NavigationView {
            // Preview loading state
            ProfileView(userId: "loading")
        }
        .previewDisplayName("Loading State")
    }
}
