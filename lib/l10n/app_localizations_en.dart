// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get appName => 'Data7 Expedition';

  @override
  String get appDescription => 'Data7 expedition system';

  @override
  String get loginTitle => 'Please login to continue';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get registerText => 'Register';

  @override
  String get registerTitle => 'Create New Account';

  @override
  String get registerSubtitle => 'Fill in the data to create your account';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Enter the password again';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get registerButton => 'Create Account';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get loginSystem => 'System Login';

  @override
  String get configurationNeeded => 'Configuration Required';

  @override
  String get configure => 'Configure';

  @override
  String get usernameRequired => 'Please enter your username';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String passwordMinLength(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String nameMaxLength(int maxLength) {
    return 'Name must be at most $maxLength characters';
  }

  @override
  String passwordMaxLength(int maxLength) {
    return 'Password must be at most $maxLength characters';
  }

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get emailRequired => 'Please enter an email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String fieldRequired(String fieldName) {
    return 'Please enter $fieldName';
  }

  @override
  String fieldMustBeNumber(String fieldName) {
    return '$fieldName must be a valid number';
  }

  @override
  String fieldMinLength(String fieldName, int minLength) {
    return '$fieldName must be at least $minLength characters';
  }

  @override
  String fieldMaxLength(String fieldName, int maxLength) {
    return '$fieldName must be at most $maxLength characters';
  }

  @override
  String get codeMustBeNumeric => 'Code must be numeric';

  @override
  String get invalidOrigin => 'Invalid origin';

  @override
  String get invalidSituation => 'Invalid situation';

  @override
  String get invalidEntityType => 'Invalid entity type (must be C or F)';

  @override
  String get configTitle => 'Settings';

  @override
  String get configSubtitle => 'Configure API URL and port';

  @override
  String get serverConfigTitle => 'Server Configuration';

  @override
  String get scannerConfigTitle => 'Scanner Configuration';

  @override
  String get scannerModeLabel => 'Reading Mode';

  @override
  String get scannerModeFocus => 'Focus/Keyboard (focused field)';

  @override
  String get scannerModeBroadcast => 'Broadcast (intent)';

  @override
  String get broadcastActionLabel => 'Broadcast Action';

  @override
  String get broadcastExtraLabel => 'Extra Key (barcode)';

  @override
  String get scannerConfigSaved => 'Scanner preferences saved!';

  @override
  String get scannerConfigMenu => 'Scanner Configuration';

  @override
  String get apiUrl => 'API URL';

  @override
  String get apiPort => 'Port';

  @override
  String get apiUrlHint => 'Ex: 192.168.1.100';

  @override
  String get apiPortHint => 'Ex: 8080';

  @override
  String get useHttps => 'Use HTTPS';

  @override
  String get httpsSubtitle => 'Secure connection (SSL/TLS)';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get previewUrl => 'URL Preview';

  @override
  String get saveConfig => 'Save Configuration';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get defaultUrl => 'localhost';

  @override
  String get defaultPort => '3001';

  @override
  String get urlRequired => 'Please enter the API URL';

  @override
  String get portRequired => 'Please enter the port';

  @override
  String get portInvalid => 'Port must be a number between 1 and 65535';

  @override
  String get registerSuccess => 'Account created successfully!';

  @override
  String get configSaved => 'Configuration saved successfully!';

  @override
  String get connectionSuccess => 'Connection successful!';

  @override
  String get profileSaved => 'Profile updated successfully!';

  @override
  String get passwordChangedSuccess => 'Password changed successfully!';

  @override
  String get profileAndPasswordSaved =>
      'Profile and password updated successfully!';

  @override
  String get registerError => 'Error creating account';

  @override
  String get connectionError => 'Error connecting to server';

  @override
  String get configError => 'Error saving configuration';

  @override
  String get loginError => 'Error logging in';

  @override
  String get genericError => 'An unexpected error occurred';

  @override
  String get networkError => 'Network connection error';

  @override
  String get timeoutError => 'Connection timeout exceeded';

  @override
  String get serverNotConfigured =>
      'Server not configured! Configure the server before logging in.';

  @override
  String get serverNotTested =>
      'Server not tested! Test the server connection before logging in.';

  @override
  String get loadConfigError => 'Error loading configuration';

  @override
  String get resetConfigError => 'Error resetting configuration';

  @override
  String get apiUrlEmptyError => 'API URL cannot be empty';

  @override
  String get portRangeError => 'Port must be a number between 1 and 65535';

  @override
  String get invalidServerResponse => 'Invalid server response';

  @override
  String connectionFailedStatus(int statusCode) {
    return 'Connection failed: Status $statusCode';
  }

  @override
  String get connectionTimeout => 'Connection timeout';

  @override
  String get receiveTimeout => 'Response timeout';

  @override
  String get connectionCheckError => 'Connection error - Check URL and port';

  @override
  String get badServerResponse => 'Invalid server response';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get connectionFailurePrefix => 'Connection error';

  @override
  String get profileError => 'Error updating profile';

  @override
  String get currentPasswordRequired =>
      'Current password is required to change password';

  @override
  String get currentPasswordIncorrect => 'Incorrect current password';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get passwordMinLengthProfile =>
      'New password must be at least 4 characters';

  @override
  String get confirmNewPasswordRequired =>
      'New password confirmation is required';

  @override
  String get passwordsDoNotMatchProfile => 'Passwords do not match';

  @override
  String get photoProcessingError => 'Error processing image';

  @override
  String get passwordChangeError => 'Error changing password';

  @override
  String validationError(String errors) {
    return 'Invalid data: $errors';
  }

  @override
  String get connectionFailure =>
      'Connection failure. Check your internet and try again.';

  @override
  String get timeoutConnection => 'Connection timeout';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get serverError => 'Server error';

  @override
  String get unauthenticated => 'User not authenticated';

  @override
  String get unauthorized => 'Access denied';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get dataProcessingError => 'Error processing data. Please try again.';

  @override
  String entityNotFound(String entity) {
    return '$entity not found';
  }

  @override
  String parsingError(String details) {
    return 'Error processing data: $details';
  }

  @override
  String repositoryError(String exception) {
    return 'Repository error: $exception';
  }

  @override
  String invalidState(String details) {
    return 'Invalid state: $details';
  }

  @override
  String operationNotAllowed(String reason) {
    return 'Operation not allowed: $reason';
  }

  @override
  String get unknownError => 'Unexpected error. Please try again.';

  @override
  String unknownErrorDetails(String exception) {
    return 'Unexpected error: $exception';
  }

  @override
  String get httpsProtocol => 'https';

  @override
  String get httpProtocol => 'http';

  @override
  String get apiEndpoint => '/expedicao';

  @override
  String get expectedApiMessage => 'Expedition API';

  @override
  String get loading => 'Loading...';

  @override
  String get connecting => 'Connecting...';

  @override
  String get saving => 'Saving...';

  @override
  String get testing => 'Testing...';

  @override
  String get loadingApp => 'Loading application...';

  @override
  String get initializing => 'Initializing...';

  @override
  String get settings => 'Settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Try Again';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileSubtitle => 'Manage your personal information';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get changePasswordSection => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get currentPasswordHint => 'Enter your current password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordHint => 'Enter the new password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get confirmNewPasswordHint => 'Enter the new password again';

  @override
  String get saveProfile => 'Save Changes';

  @override
  String get settingsTooltip => 'Open settings';

  @override
  String get backTooltip => 'Back';

  @override
  String get refreshTooltip => 'Refresh data';

  @override
  String get lastReading => 'Last reading';

  @override
  String get lastReadingColon => 'Last reading:';

  @override
  String get clearReading => 'Clear Reading';

  @override
  String get shelfCode => 'Shelf Code';

  @override
  String get waitProcessing => 'Please wait, processing item...';

  @override
  String get typeBarcodeManually =>
      'Type the barcode manually or tap the icon to use the scanner';

  @override
  String get positionProductScanner =>
      'Position the product on the scanner or tap the icon to use the keyboard';

  @override
  String get scannerDisabled =>
      'Scanner disabled - cart is not in separation status';

  @override
  String get cancelCart => 'Cancel Cart';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get appName => 'Data7 Expedition';

  @override
  String get appDescription => 'Data7 expedition system';

  @override
  String get loginTitle => 'Please login to continue';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get registerText => 'Register';

  @override
  String get registerTitle => 'Create New Account';

  @override
  String get registerSubtitle => 'Fill in the data to create your account';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Enter the password again';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get registerButton => 'Create Account';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get loginSystem => 'System Login';

  @override
  String get configurationNeeded => 'Configuration Required';

  @override
  String get configure => 'Configure';

  @override
  String get usernameRequired => 'Please enter your username';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String passwordMinLength(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String nameMaxLength(int maxLength) {
    return 'Name must be at most $maxLength characters';
  }

  @override
  String passwordMaxLength(int maxLength) {
    return 'Password must be at most $maxLength characters';
  }

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get emailRequired => 'Please enter an email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String fieldRequired(String fieldName) {
    return 'Please enter $fieldName';
  }

  @override
  String fieldMustBeNumber(String fieldName) {
    return '$fieldName must be a valid number';
  }

  @override
  String fieldMinLength(String fieldName, int minLength) {
    return '$fieldName must be at least $minLength characters';
  }

  @override
  String fieldMaxLength(String fieldName, int maxLength) {
    return '$fieldName must be at most $maxLength characters';
  }

  @override
  String get codeMustBeNumeric => 'Code must be numeric';

  @override
  String get invalidOrigin => 'Invalid origin';

  @override
  String get invalidSituation => 'Invalid situation';

  @override
  String get invalidEntityType => 'Invalid entity type (must be C or F)';

  @override
  String get configTitle => 'Settings';

  @override
  String get configSubtitle => 'Configure API URL and port';

  @override
  String get serverConfigTitle => 'Server Configuration';

  @override
  String get scannerConfigTitle => 'Scanner Configuration';

  @override
  String get scannerModeLabel => 'Reading Mode';

  @override
  String get scannerModeFocus => 'Focus/Keyboard (focused field)';

  @override
  String get scannerModeBroadcast => 'Broadcast (intent)';

  @override
  String get broadcastActionLabel => 'Broadcast Action';

  @override
  String get broadcastExtraLabel => 'Extra Key (barcode)';

  @override
  String get scannerConfigSaved => 'Scanner preferences saved!';

  @override
  String get scannerConfigMenu => 'Scanner Configuration';

  @override
  String get apiUrl => 'API URL';

  @override
  String get apiPort => 'Port';

  @override
  String get apiUrlHint => 'Ex: 192.168.1.100';

  @override
  String get apiPortHint => 'Ex: 8080';

  @override
  String get useHttps => 'Use HTTPS';

  @override
  String get httpsSubtitle => 'Secure connection (SSL/TLS)';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get previewUrl => 'URL Preview';

  @override
  String get saveConfig => 'Save Configuration';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get defaultUrl => 'localhost';

  @override
  String get defaultPort => '3001';

  @override
  String get urlRequired => 'Please enter the API URL';

  @override
  String get portRequired => 'Please enter the port';

  @override
  String get portInvalid => 'Port must be a number between 1 and 65535';

  @override
  String get registerSuccess => 'Account created successfully!';

  @override
  String get configSaved => 'Configuration saved successfully!';

  @override
  String get connectionSuccess => 'Connection successful!';

  @override
  String get profileSaved => 'Profile updated successfully!';

  @override
  String get passwordChangedSuccess => 'Password changed successfully!';

  @override
  String get profileAndPasswordSaved =>
      'Profile and password updated successfully!';

  @override
  String get registerError => 'Error creating account';

  @override
  String get connectionError => 'Error connecting to server';

  @override
  String get configError => 'Error saving configuration';

  @override
  String get loginError => 'Error logging in';

  @override
  String get genericError => 'An unexpected error occurred';

  @override
  String get networkError => 'Network connection error';

  @override
  String get timeoutError => 'Connection timeout exceeded';

  @override
  String get serverNotConfigured =>
      'Server not configured! Configure the server before logging in.';

  @override
  String get serverNotTested =>
      'Server not tested! Test the server connection before logging in.';

  @override
  String get loadConfigError => 'Error loading configuration';

  @override
  String get resetConfigError => 'Error resetting configuration';

  @override
  String get apiUrlEmptyError => 'API URL cannot be empty';

  @override
  String get portRangeError => 'Port must be a number between 1 and 65535';

  @override
  String get invalidServerResponse => 'Invalid server response';

  @override
  String connectionFailedStatus(int statusCode) {
    return 'Connection failed: Status $statusCode';
  }

  @override
  String get connectionTimeout => 'Connection timeout';

  @override
  String get receiveTimeout => 'Response timeout';

  @override
  String get connectionCheckError => 'Connection error - Check URL and port';

  @override
  String get badServerResponse => 'Invalid server response';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get connectionFailurePrefix => 'Connection error';

  @override
  String get profileError => 'Error updating profile';

  @override
  String get currentPasswordRequired =>
      'Current password is required to change password';

  @override
  String get currentPasswordIncorrect => 'Incorrect current password';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get passwordMinLengthProfile =>
      'New password must be at least 4 characters';

  @override
  String get confirmNewPasswordRequired =>
      'New password confirmation is required';

  @override
  String get passwordsDoNotMatchProfile => 'Passwords do not match';

  @override
  String get photoProcessingError => 'Error processing image';

  @override
  String get passwordChangeError => 'Error changing password';

  @override
  String validationError(String errors) {
    return 'Invalid data: $errors';
  }

  @override
  String get connectionFailure =>
      'Connection failure. Check your internet and try again.';

  @override
  String get timeoutConnection => 'Connection timeout';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get serverError => 'Server error';

  @override
  String get unauthenticated => 'User not authenticated';

  @override
  String get unauthorized => 'Access denied';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get dataProcessingError => 'Error processing data. Please try again.';

  @override
  String entityNotFound(String entity) {
    return '$entity not found';
  }

  @override
  String parsingError(String details) {
    return 'Error processing data: $details';
  }

  @override
  String repositoryError(String exception) {
    return 'Repository error: $exception';
  }

  @override
  String invalidState(String details) {
    return 'Invalid state: $details';
  }

  @override
  String operationNotAllowed(String reason) {
    return 'Operation not allowed: $reason';
  }

  @override
  String get unknownError => 'Unexpected error. Please try again.';

  @override
  String unknownErrorDetails(String exception) {
    return 'Unexpected error: $exception';
  }

  @override
  String get httpsProtocol => 'https';

  @override
  String get httpProtocol => 'http';

  @override
  String get apiEndpoint => '/expedicao';

  @override
  String get expectedApiMessage => 'Expedition API';

  @override
  String get loading => 'Loading...';

  @override
  String get connecting => 'Connecting...';

  @override
  String get saving => 'Saving...';

  @override
  String get testing => 'Testing...';

  @override
  String get loadingApp => 'Loading application...';

  @override
  String get initializing => 'Initializing...';

  @override
  String get settings => 'Settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Try Again';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileSubtitle => 'Manage your personal information';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get changePasswordSection => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get currentPasswordHint => 'Enter your current password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordHint => 'Enter the new password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get confirmNewPasswordHint => 'Enter the new password again';

  @override
  String get saveProfile => 'Save Changes';

  @override
  String get settingsTooltip => 'Open settings';

  @override
  String get backTooltip => 'Back';

  @override
  String get refreshTooltip => 'Refresh data';

  @override
  String get lastReading => 'Last reading';

  @override
  String get lastReadingColon => 'Last reading:';

  @override
  String get clearReading => 'Clear Reading';

  @override
  String get shelfCode => 'Shelf Code';

  @override
  String get waitProcessing => 'Please wait, processing item...';

  @override
  String get typeBarcodeManually =>
      'Type the barcode manually or tap the icon to use the scanner';

  @override
  String get positionProductScanner =>
      'Position the product on the scanner or tap the icon to use the keyboard';

  @override
  String get scannerDisabled =>
      'Scanner disabled - cart is not in separation status';

  @override
  String get cancelCart => 'Cancel Cart';
}
