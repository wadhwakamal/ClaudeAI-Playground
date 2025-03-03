import Foundation
import SwiftData

@Model
final class User: Identifiable {
    @Attribute(.unique) var id = UUID()
    var name: String
    var username: String
    var bio: String
    var profileImageName: String = "person.circle.fill" // Default system image
    var postCount: Int
    var followerCount: Int
    var followingCount: Int
    
    // SwiftData can't directly store arrays of custom types, so we'll use relationships
    @Relationship(deleteRule: .cascade) var activities: [ActivityItem] = []
    
    init(name: String, username: String, bio: String, profileImageName: String = "person.circle.fill",
         postCount: Int, followerCount: Int, followingCount: Int) {
        self.name = name
        self.username = username
        self.bio = bio
        self.profileImageName = profileImageName
        self.postCount = postCount
        self.followerCount = followerCount
        self.followingCount = followingCount
    }
    
    // For compatibility with our existing code
    var recentActivities: [Activity] {
        return activities.map { 
            Activity(description: $0.desc, timeAgo: $0.timeAgo)
        }
    }
    
    // This will create a sample user with mock data
    static var sample: User {
        let user = User(
            name: "John Doe",
            username: "@johndoe",
            bio: "iOS Developer | SwiftUI Enthusiast | Coffee Lover",
            postCount: 42,
            followerCount: 589,
            followingCount: 217
        )
        
        // Sample activities
        let sampleActivities = [
            ActivityItem(description: "Posted a new photo", timeAgo: "2h ago"),
            ActivityItem(description: "Liked a post", timeAgo: "4h ago"),
            ActivityItem(description: "Commented on a thread", timeAgo: "1d ago"),
            ActivityItem(description: "Started following @swiftui_tips", timeAgo: "2d ago")
        ]
        
        user.activities = sampleActivities
        return user
    }
}

// SwiftData compatible Activity model
@Model
final class ActivityItem: Identifiable {
    @Attribute(.unique) var id = UUID()
    var desc: String
    var timeAgo: String
    
    init(description: String, timeAgo: String) {
        self.desc = description
        self.timeAgo = timeAgo
    }
}

// Non-SwiftData struct for use in views
struct Activity: Identifiable {
    var id = UUID()
    var description: String
    var timeAgo: String
}

// For Codable support (needed for API)
extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, username, bio, profileImageName, postCount, followerCount, followingCount
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        let username = try container.decode(String.self, forKey: .username)
        let bio = try container.decode(String.self, forKey: .bio)
        let profileImageName = try container.decode(String.self, forKey: .profileImageName)
        let postCount = try container.decode(Int.self, forKey: .postCount)
        let followerCount = try container.decode(Int.self, forKey: .followerCount)
        let followingCount = try container.decode(Int.self, forKey: .followingCount)
        
        self.init(
            name: name,
            username: username,
            bio: bio,
            profileImageName: profileImageName,
            postCount: postCount,
            followerCount: followerCount,
            followingCount: followingCount
        )
        
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(bio, forKey: .bio)
        try container.encode(profileImageName, forKey: .profileImageName)
        try container.encode(postCount, forKey: .postCount)
        try container.encode(followerCount, forKey: .followerCount)
        try container.encode(followingCount, forKey: .followingCount)
    }
}
