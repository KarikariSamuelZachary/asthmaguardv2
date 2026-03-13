class Constants {
  // Provide at build time: flutter build --dart-define=NODE_API_URL=https://your-api.com
  static const String nodeApiUrl = String.fromEnvironment(
    'NODE_API_URL',
    defaultValue: 'http://localhost:3000',
  );
}
