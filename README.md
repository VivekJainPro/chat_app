
# Flutter Chat App

A real-time chat application built with Flutter and Firebase, supporting both public and private messaging with file sharing capabilities. [main.dart (lines 24–25)](./lib/main.dart#L24-L25)
 

## Features

- **Real-time Authentication**: Firebase Authentication with automatic state management [2](#0-1) 
- **Public Chat Rooms**: Group messaging functionality [3](#0-2) 
- **Private Messaging**: One-on-one conversations between users [4](#0-3) 
- **File Sharing**: Upload and share files in conversations [5](#0-4) 
- **Web Deployment**: Optimized for web deployment on GitHub Pages [6](#0-5) 
- **Progressive Web App**: PWA capabilities for mobile web experience [7](#0-6) 

## Architecture

The application follows a layered architecture with Firebase integration:

- **Entry Point**: `main.dart` initializes Firebase and handles authentication routing [8](#0-7) 
- **Authentication Flow**: StreamBuilder-based routing between auth and main screens [9](#0-8) 
- **Theme**: Dark theme with custom teal color scheme [10](#0-9) 

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase project with Authentication, Firestore, and Storage enabled
- Web deployment requires CORS configuration for Firebase services

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your `firebase_options.dart` configuration
   - Set up CORS rules for web deployment [11](#0-10) 

### Running the App

```bash
# Run on mobile/desktop
flutter run

# Build for web
flutter build web --base-href="/chat_app/"
```

## Web Deployment

The app is configured for GitHub Pages deployment with:
- Base href set to `/chat_app/` [6](#0-5) 
- PWA manifest for mobile web app capabilities [12](#0-11) 
- CORS configuration allowing requests from `vivekjainpro.github.io` [13](#0-12) 

## Testing

The project includes widget tests with Firebase integration: [14](#0-13) 

```bash
flutter test
```

## Project Structure

```
lib/
├── main.dart              # App entry point and routing
├── screeen/
│   ├── auth.dart         # Authentication screen
│   ├── homepage.dart     # User list and navigation
│   ├── chat.dart         # Public chat screen
│   └── pvt_chat.dart     # Private messaging
web/
├── index.html            # Web app entry point
└── manifest.json         # PWA configuration
```

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Firebase Authentication**: User authentication
- **Cloud Firestore**: Real-time database
- **Firebase Storage**: File storage and sharing
- **GitHub Pages**: Web hosting platform

## Notes

The application demonstrates a complete real-time chat solution with modern web deployment practices. The authentication system uses Firebase's `authStateChanges()` stream for automatic login state management, while the web deployment configuration ensures proper CORS handling for Firebase services. The codebase includes both public group chat and private messaging features with file sharing capabilities through Firebase Storage.

Wiki pages you might want to explore:
- [Flutter Application (VivekJainPro/chat_app)](/wiki/VivekJainPro/chat_app#2)
- [Web Application Deployment (VivekJainPro/chat_app)](/wiki/VivekJainPro/chat_app#4)
