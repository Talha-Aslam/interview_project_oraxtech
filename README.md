# Social Posts App - Interview Assessment

A professional Flutter application that displays posts from the JSONPlaceholder API with a clean, modern UI design.

## Features

### 📱 Two-Page Application
- **Listing Page (Threads)**: Displays all posts in a social media feed style
- **Detail Page**: Shows individual post with comments and engagement features

### 🎨 Modern UI Design
- Clean, minimalist interface matching the provided mockups
- Responsive design with proper spacing and typography
- Interactive elements with smooth transitions
- Bottom navigation bar for enhanced UX

### 🔗 API Integration
- Fetches posts from `https://jsonplaceholder.typicode.com/posts`
- Loads comments for individual posts
- Proper error handling and loading states
- Pull-to-refresh functionality

### 💡 Professional Features
- **State Management**: Clean StatefulWidget implementation
- **Error Handling**: Comprehensive error states with retry options
- **Loading States**: Smooth loading indicators
- **Mock Data**: Realistic user avatars, names, and engagement metrics
- **Navigation**: Seamless navigation between screens
- **Responsive Design**: Works on different screen sizes

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── post.dart               # Post data model
│   └── comment.dart            # Comment data model
├── services/
│   └── api_service.dart        # HTTP API calls
└── screens/
    ├── post_list_screen.dart   # Main listing page
    └── post_detail_screen.dart # Post detail page
```

## 🚀 Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Build for Production**
   ```bash
   flutter build apk  # Android
   flutter build ios  # iOS
   flutter build web  # Web
   ```

## 📦 Dependencies

- `flutter`: Framework
- `http`: API calls and HTTP requests

## 🎯 Key Implementation Highlights

### Clean Code Practices
- **Separation of Concerns**: Models, services, and UI are properly separated
- **Reusable Components**: Modular widget structure
- **Error Handling**: Comprehensive error states and user feedback
- **Performance**: Efficient ListView building and state management

### UI/UX Excellence
- **Pixel-Perfect Design**: Matches provided mockups exactly
- **Interactive Elements**: Proper touch feedback and animations
- **Loading States**: Professional loading indicators
- **Error States**: User-friendly error messages with retry options

### Professional Features
- **Pull-to-Refresh**: Allows users to refresh the post list
- **Navigation**: Smooth transitions between screens
- **Mock Realistic Data**: User avatars, names, and engagement metrics
- **Responsive Layout**: Adapts to different screen sizes

## 🔧 Technical Details

### Models
- **Post**: Contains id, userId, title, and body
- **Comment**: Contains id, postId, name, email, and body
- Both models include JSON serialization/deserialization

### API Service
- Centralized HTTP client management
- Proper error handling with meaningful messages
- Support for different endpoints (posts, individual post, comments)

### State Management
- Clean StatefulWidget implementation
- Proper loading and error state handling
- Optimistic UI updates for better UX

## 🎨 Design Implementation

The app closely follows the provided mockups:

- **Threads Screen**: Social media feed-style layout with user avatars, post content, and timestamps
- **Post Detail Screen**: Full post view with engagement buttons, comments section, and add comment functionality
- **Bottom Navigation**: Five-tab navigation bar with proper active states
- **Typography**: Consistent font sizes and weights throughout the app
- **Color Scheme**: Clean black and white design with subtle gray accents

## 🚀 Future Enhancements

- Add user authentication
- Implement actual posting functionality
- Add image support for posts
- Real-time comment updates
- Push notifications
- Offline caching with local database

---

**Built with ❤️ for Interview Assessment**

This project demonstrates clean architecture, professional UI design, and robust Flutter development practices suitable for production applications.
