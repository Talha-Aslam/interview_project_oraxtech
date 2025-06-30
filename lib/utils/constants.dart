import 'package:flutter/material.dart';

/// App-wide constants for consistent styling and configuration
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration apiTimeout = Duration(seconds: 10);

  // Colors
  static const Color primaryColor = Colors.black;
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;

  // Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle postTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.3,
  );

  static const TextStyle postBodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  );

  static const TextStyle userNameStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle commentStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    height: 1.4,
  );

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Avatar Colors for consistent user representation
  static const List<Color> avatarColors = [
    Color(0xFF64B5F6), // Blue 300
    Color(0xFF81C784), // Green 300
    Color(0xFFFFB74D), // Orange 300
    Color(0xFFBA68C8), // Purple 300
    Color(0xFFE57373), // Red 300
    Color(0xFF4FC3F7), // Light Blue 300
    Color(0xFFA1C181), // Light Green 300
    Color(0xFFFFCC02), // Amber 300
  ];

  // Mock User Names for demo
  static const List<String> mockUserNames = [
    'Sophia Bennett',
    'Ethan Carter',
    'Olivia Davis',
    'Liam Foster',
    'Ava Green',
    'Noah Williams',
    'Emma Johnson',
    'Lucas Brown',
    'Isabella White',
    'Mason Taylor',
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Default Engagement Counts (for demo)
  static const int defaultLikeCount = 67;
  static const int defaultShareCount = 5;

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection and try again.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String timeoutErrorMessage =
      'Request took too long. Please try again.';
  static const String noDataMessage = 'No data available.';

  // Success Messages
  static const String commentAddedMessage = 'Comment added successfully!';
  static const String postLikedMessage = 'Post liked!';
  static const String postUnlikedMessage = 'Post unliked!';
}

/// Extension methods for common UI patterns
extension AppTheme on ThemeData {
  static ThemeData get appTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'System',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.primaryColor),
        titleTextStyle: AppConstants.appBarTitleStyle,
      ),
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
      ),
    );
  }
}

/// Utility functions for common operations
class AppUtils {
  /// Get avatar color for a given index
  static Color getAvatarColor(int index) {
    return AppConstants.avatarColors[index % AppConstants.avatarColors.length];
  }

  /// Get mock user name for a given index
  static String getMockUserName(int index) {
    return AppConstants
        .mockUserNames[index % AppConstants.mockUserNames.length];
  }

  /// Get user initials from name
  static String getUserInitials(String name) {
    return name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join('')
        .toUpperCase();
  }

  /// Format time ago (mock implementation)
  static String getTimeAgo(int index) {
    if (index < 2) return '1h';
    if (index < 5) return '2h';
    if (index < 10) return '1d';
    return '2d';
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
