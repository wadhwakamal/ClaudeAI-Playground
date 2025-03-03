# ClaudeAI-DemoApp

![](https://github.com/wadhwakamal/ClaudeAI-Playground/blob/main/Images/simulator-demo.jpeg)

A dynamic Xcode project generated via prompts from the ClaudeAI Desktop App. This project is designed to experiment with AI-driven development and includes a robust architecture featuring a ProfileView, a network layer, and a ViewModel utilizing SwiftData.

Claude Playground is an experimental project where AI meets iOS/macOS development. The entire project was prompted and partially generated using the ClaudeAI Desktop App.

## 📱 Features

- **Modern Swift Concurrency**: Implemented with async/await for clean, efficient networking
- **SwiftData Integration**: Persistent storage using Apple's latest data framework
- **Clean Architecture**: Separation of concerns with MVVM pattern
- **Authentication Flow**: Complete login/logout functionality with token management
- **Profile Management**: User profile display and editing capabilities
- **Secure Storage**: Keychain integration for secure token storage

## 🏗️ Project Structure

```
ClaudeAI-DemoApp/
├── Models/
│   └── User.swift                  # User and Activity models with SwiftData integration
├── Views/
│   ├── LoginView.swift             # Authentication UI
│   ├── MainTabView.swift           # Main tabbed interface
│   └── ProfileView.swift           # User profile display and editing
├── ViewModels/
│   ├── AuthViewModel.swift         # Authentication logic
│   └── UserViewModel.swift         # User data management
├── Networking/
│   ├── APIClient.swift             # API request handling
│   ├── NetworkCore.swift           # Core networking protocols and types
│   ├── NetworkService.swift        # Network request implementation
│   └── TokenManager.swift          # Authentication token management
└── ClaudeAI_DemoAppApp.swift       # App entry point
```

## 🔄 Architecture Overview

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures that represent the app's domain.
- **Views**: SwiftUI views that display data and handle user interactions.
- **ViewModels**: Mediators between the models and views, handling business logic and state.
- **Networking**: A separate layer for API communication.

## 🌐 Networking Layer

The networking layer is built with modern Swift concurrency (async/await) and follows these principles:

1. **Protocol-Oriented**: All components are defined by protocols for testability
2. **Type-Safe**: Strong typing throughout the entire networking stack
3. **Flexible**: Support for different HTTP methods, headers, body data, etc.
4. **Error Handling**: Comprehensive error types and handling strategies
5. **Authentication**: Automatic token management and request authorization

### Key Components:

- `APIEndpoint`: Protocol for defining API endpoints
- `NetworkService`: Core service for making network requests
- `APIClient`: Client for making specific API calls
- `TokenManager`: Handles authentication token storage and refresh

## 🔐 Authentication

The app implements a token-based authentication system:

- **Login Flow**: Email/password authentication that returns JWT tokens
- **Token Storage**: Secure storage in the iOS Keychain
- **Auto-Refresh**: Support for refreshing expired tokens
- **Logout**: Proper token cleanup

## 💾 Data Persistence

The app uses SwiftData for local data storage:

- **Models**: SwiftData-compatible model objects
- **Relationships**: Proper handling of object relationships
- **Schema Management**: Versioned schema for data migration
- **Integration**: Seamless integration with SwiftUI via environment

## 👤 User Profile

The ProfileView demonstrates:

- **Data Display**: Clean presentation of user information
- **Async Loading**: Loading states with proper error handling
- **Pull-to-Refresh**: Modern refresh mechanism
- **Activity List**: Display of user activity history

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation

1. Clone the repository:

```bash
git clone git@github.com:wadhwakamal/ClaudeAI-Playground.git
```

2. Open the project in Xcode:

```bash
cd ClaudeAI-Playground
open ClaudeAI-DemoApp.xcodeproj
```

3. Build and run the project on your device or simulator.

## 📚 Best Practices Demonstrated

- **Error Handling**: Comprehensive approach to network and system errors
- **Dependency Injection**: All components accept dependencies for better testability
- **SwiftUI Best Practices**: Proper view composition and state management
- **Concurrency**: Modern async/await pattern usage
- **Security**: Proper handling of sensitive data

## 🛠️ Future Improvements

- Add more robust error handling for edge cases
- Add offline support with local caching
- Implement comprehensive analytics
- Add localization support

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **ClaudeAI Desktop App**: For enabling a unique AI-driven approach to project generation.
- **[xcode-mcp-server](https://github.com/r-huijts/xcode-mcp-server)**: Special thanks to r-huijts for the server that bridges the ClaudeAI Desktop App and the Xcode project.
