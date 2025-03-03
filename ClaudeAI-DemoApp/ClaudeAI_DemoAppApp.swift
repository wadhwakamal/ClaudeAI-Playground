//
//  ClaudeAI_DemoAppApp.swift
//  ClaudeAI-DemoApp
//
//  Created by Kamal Wadhwa on 02/03/25.
//

import SwiftUI
import SwiftData

@main
struct ClaudeAI_DemoAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            User.self,
            ActivityItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .onAppear {
                // Check authentication status when app starts
                authViewModel.checkAuthentication()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
