class AppConstants {
  // App Identity
  static const String appName = 'Visitor Management';
  static const String appSubtitle = 'Safe Visits. Better Spaces.';
  static const String defaultUser = 'Front Desk Security';

  // Navigation Items
  static const String navHome = 'Home';
  static const String navVisitors = 'Visitors';
  static const String navScan = 'Scan';
  static const String navStats = 'Stats';

  // Screen & AppBar Titles
  static const String titleDashboard = 'Dashboard';
  static const String titleVisitorList = 'Visitor Management';
  static const String titleVisitorDetails = 'Visitor Details';
  static const String titleRegisterVisitor = 'Register Visitor';
  static const String titleEditVisitor = 'Edit Visitor';
  static const String titleVisitorQRCode = 'Visitor QR Code';
  static const String titleScanQR = 'Scan QR Code';
  static const String titleScanVisitorQR = 'Scan Visitor QR';
  static const String titleVisitorInfo = 'Visitor Information';
  static const String titleStatistics = 'Visitor Statistics';
  static const String filterVisitorsTitle = 'Filter Visitors';
  static const String titleManualInput = 'Enter Visitor ID';
  static const String titleCameraUnavailable = 'Camera Unavailable or Permission Denied';

  // Auth & Login
  static const String welcomeBack = 'Welcome back!';
  static const String labelUsername = 'Username';
  static const String labelPassword = 'Password';
  static const String labelLogin = 'Login';
  static const String labelLogOut = 'Log Out';
  static const String errorEnterUsername = 'Please enter your username';
  static const String errorEnterPassword = 'Please enter your password';
  static const String hintUsername = 'Enter username';
  static const String hintPassword = 'Enter password';

  // Dashboard Metrics & Sections
  static const String totalVisitorsToday = 'Total Visitors Today';
  static const String currentlyCheckedIn = 'Currently Checked In';
  static const String checkedOutToday = 'Checked Out Today';
  static const String statTotalToday = 'Total Visitors\nToday';
  static const String statCheckedIn = 'Currently\nChecked In';
  static const String statCheckedOut = 'Checked Out\nToday';
  static const String quickActions = 'Quick Actions';
  static const String registerVisitor = 'Register Visitor';
  static const String actionRegisterVisitor = 'Register\nVisitor';
  static const String actionVisitorList = 'Visitor\nList';
  static const String actionScanQRCode = 'Scan\nQR Code';
  static const String recentActivity = 'Recent Activity';
  static const String viewAll = 'View All';
  static const String noVisitorsToday = 'No visitor records for today';

  // Visitor Form Labels & Hints
  static const String labelVisitorName = 'Visitor Name';
  static const String hintVisitorName = 'Enter visitor name';
  static const String labelMobileNumber = 'Mobile Number';
  static const String hintMobileNumber = 'Enter 10 digit mobile number';
  static const String labelEmail = 'Email';
  static const String labelEmailOptional = 'Email (Optional)';
  static const String hintEmail = 'Enter email address';
  static const String labelVisitorType = 'Visitor Type';
  static const String hintVisitorType = 'Select visitor type';
  static const String labelProject = 'Project';
  static const String hintProject = 'Select project';
  static const String labelPurpose = 'Purpose of Visit';
  static const String hintPurpose = 'Enter purpose of visit';
  static const String labelVisitorId = 'Visitor ID';
  static const String hintVisitorId = 'e.g. VST001';
  static const String labelRegisteredOn = 'Registered On';
  static const String labelCheckInTime = 'Check-In Time';
  static const String labelCheckOutTime = 'Check-Out Time';
  static const String labelStatus = 'Status';
  static const String labelTotal = 'Total';

  // Form Buttons & Actions
  static const String cancel = 'Cancel';
  static const String register = 'Register';
  static const String saveChanges = 'Save Changes';
  static const String btnSave = 'Save';
  static const String btnUpdate = 'Update';
  static const String reset = 'Reset';
  static const String delete = 'Delete';
  static const String editVisitor = 'Edit Visitor';
  static const String deleteVisitor = 'Delete Visitor';
  static const String actionCheckIn = 'Check In';
  static const String actionCheckOut = 'Check Out';
  static const String actionScanToCheckOut = 'Scan to Check Out';
  static const String statusCompleted = 'Visit Completed';
  static const String tapToViewDownloadQR = 'Tap to View / Download QR';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String find = 'Find';
  static const String enterIdManually = 'Enter ID Manually';
  static const String enterVisitorIdManually = 'Enter Visitor ID Manually';

  // Search & Filters
  static const String searchHint = 'Search by name or mobile number';
  static const String filteredBy = 'Filtered by:';
  static const String noMatchesFound = 'No matches found';
  static const String noVisitorsRegistered = 'No Visitors Registered';
  static const String registerNewVisitorPrompt = 'Register a new visitor to get started';
  static const String noVisitorsFound = 'No visitors found for';
  static const String loadingVisitors = 'Loading visitors...';
  static const String errorLoadingVisitors = 'Error loading visitors';

  // QR Code & Downloads
  static const String downloadQRCode = 'Download QR Code';
  static const String savingToDownloads = 'Saving to Downloads...';
  static const String qrSecurityNotice = 'Show this QR code at the security desk upon arrival';
  static const String qrDownloadedPrefix = 'QR Code downloaded to Downloads folder:';
  static const String qrDownloadFailedPrefix = 'Failed to download QR code:';
  static const String qrSavedPrefix = 'Saved:';
  static const String alignQRNotice = 'Place the QR code within the frame';
  static const String cameraPermissionNotice = 'You can still test and verify scanning by entering a Visitor ID manually.';

  // Dialogs
  static const String dialogDeleteTitle = 'Delete Visitor';
  static const String dialogDeleteMessage = 'Are you sure you want to delete this visitor record?';
  static const String dialogDeletePrompt = 'Are you sure you want to delete';

  // Form Validation & Errors
  static const String errorSelectTypeAndProject = 'Please select visitor type and project';

  // Success Screens
  static const String titleRegSuccess = 'Registration Successful';
  static const String titleCheckInSuccess = 'Check-In Successful';
  static const String titleCheckOutSuccess = 'Check-Out Successful';
  static const String backToDashboard = 'Back to Dashboard';
  static const String viewDetails = 'View Details';
  static const String successCheckedInWord = 'checked in';
  static const String successCheckedOutWord = 'checked out';

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
