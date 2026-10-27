class ApiConstants {
  // Default MockAPI or REST API base URL
  // Can be modified at runtime through app settings
  static const String defaultBaseUrl = 'https://67bf170be922a942a0b16f1b.mockapi.io/api/v1';

  static const String visitorsEndpoint = '/visitors';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
