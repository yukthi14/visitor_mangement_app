class AppConstants {
  static const String appName = 'Visitor Management';
  static const String appSubtitle = 'Safe Visits. Better Spaces.';

  // Visitor Types
  static const String typeCustomer = 'Customer';
  static const String typeVendor = 'Vendor';
  static const String typeOther = 'Other';

  static const List<String> visitorTypes = [
    typeCustomer,
    typeVendor,
    typeOther,
  ];

  // Projects
  static const String projectA = 'Project A';
  static const String projectB = 'Project B';
  static const String projectC = 'Project C';

  static const List<String> projects = [
    projectA,
    projectB,
    projectC,
  ];

  // Visitor Status
  static const String statusRegistered = 'Registered';
  static const String statusCheckedIn = 'Checked In';
  static const String statusCheckedOut = 'Checked Out';

  // Shared Preferences Keys
  static const String prefBaseUrl = 'pref_api_base_url';
  static const String prefCachedVisitors = 'pref_cached_visitors';
  static const String prefIsLoggedIn = 'pref_is_logged_in';
  static const String prefLoggedUser = 'pref_logged_user';
}
