class AppConstants {
  // App info
  static const String appName = 'Sales Bets';
  static const String appTagline = 'Win but never lose!';
  
  // Collections
  static const String usersCollection = 'users';
  static const String teamsCollection = 'teams';
  static const String eventsCollection = 'events';
  static const String betsCollection = 'bets';
  static const String streamsCollection = 'streams';
  static const String notificationsCollection = 'notifications';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String teamLogosPath = 'team_logos';
  static const String eventBannersPath = 'event_banners';
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration buttonAnimationDuration = Duration(milliseconds: 200);
  
  // Padding
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Default values
  static const int defaultCredits = 1000;
  
  // API Keys (Note: In production, use flutter_dotenv or similar)
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  
  // Placeholder images
  static const String placeholderProfile = 'assets/images/placeholder_profile.png';
  static const String placeholderTeam = 'assets/images/placeholder_team.png';
  static const String placeholderEvent = 'assets/images/placeholder_event.png';

  static get appVersion => null;
}
