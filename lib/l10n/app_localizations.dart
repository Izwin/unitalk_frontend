import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('az'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'UniTalky'**
  String get appName;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Complete button label
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Intro subtitle on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Connect with your university community'**
  String get introSubtitle;

  /// Introduction description
  ///
  /// In en, this message translates to:
  /// **'Stay up to date with your university life'**
  String get introDescription;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Continue with Google button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Terms agreement prefix
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get byContinuingYouAgree;

  /// Conjunction 'and'
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// Terms of Service link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Privacy Policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get errorOccurred;

  /// Generic error message alternative
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// Profile setup page title
  ///
  /// In en, this message translates to:
  /// **'Profile Setup'**
  String get profileSetup;

  /// Complete profile page title
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeProfile;

  /// Complete profile welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome aboard!'**
  String get completeProfileTitle;

  /// Complete profile subtitle
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you set up in just a few steps'**
  String get completeProfileSubtitle;

  /// Name setup question
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get whatsYourName;

  /// Real name requirement explanation
  ///
  /// In en, this message translates to:
  /// **'Use your real name to get verified and build trust in the community'**
  String get realNameRequired;

  /// Personal information section header
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInformation;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// First name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// First name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// First name validation error
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// First name length validation
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 2 characters'**
  String get firstNameTooShort;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Last name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameHint;

  /// Last name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// Last name validation error
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// Last name length validation
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 2 characters'**
  String get lastNameTooShort;

  /// Form validation error
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get fillAllFields;

  /// Academic information section header
  ///
  /// In en, this message translates to:
  /// **'Academic Info'**
  String get academicInformation;

  /// University field label
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// Select university page title
  ///
  /// In en, this message translates to:
  /// **'Select University'**
  String get selectUniversity;

  /// Select university header
  ///
  /// In en, this message translates to:
  /// **'Select your university'**
  String get selectYourUniversity;

  /// Select university description
  ///
  /// In en, this message translates to:
  /// **'Choose the university you attend'**
  String get chooseUniversityYouAttend;

  /// Select university dropdown prompt
  ///
  /// In en, this message translates to:
  /// **'Select university'**
  String get selectUniversityPrompt;

  /// University selection bottom sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a university to view its feed'**
  String get selectUniversitySubtitle;

  /// Error when faculty selected before university
  ///
  /// In en, this message translates to:
  /// **'Select a university first'**
  String get selectUniversityFirst;

  /// University search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search university...'**
  String get searchUniversity;

  /// Universities search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search universities...'**
  String get searchUniversities;

  /// University validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a university'**
  String get universityRequired;

  /// University loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load universities'**
  String get failedToLoadUniversities;

  /// Empty state for university search
  ///
  /// In en, this message translates to:
  /// **'No universities found'**
  String get noUniversitiesFound;

  /// Your university label
  ///
  /// In en, this message translates to:
  /// **'Your University'**
  String get yourUniversity;

  /// Change university hint
  ///
  /// In en, this message translates to:
  /// **'Tap to change university'**
  String get tapToChangeUniversity;

  /// Faculty field label
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get faculty;

  /// Select faculty page title
  ///
  /// In en, this message translates to:
  /// **'Select Faculty'**
  String get selectFaculty;

  /// Select faculty header
  ///
  /// In en, this message translates to:
  /// **'Select your faculty'**
  String get selectYourFaculty;

  /// Select faculty description
  ///
  /// In en, this message translates to:
  /// **'Choose your field of study'**
  String get chooseYourFieldOfStudy;

  /// Select faculty dropdown prompt
  ///
  /// In en, this message translates to:
  /// **'Select faculty'**
  String get selectFacultyPrompt;

  /// Faculty search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search faculty...'**
  String get searchFaculty;

  /// Faculties search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search faculties...'**
  String get searchFaculties;

  /// Faculty validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a faculty'**
  String get facultyRequired;

  /// Faculty loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load faculties'**
  String get failedToLoadFaculties;

  /// Empty state for faculty search
  ///
  /// In en, this message translates to:
  /// **'No faculties found'**
  String get noFacultiesFound;

  /// Sector field label
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get sector;

  /// Select sector page title
  ///
  /// In en, this message translates to:
  /// **'Select Sector'**
  String get selectSector;

  /// Select sector dropdown prompt
  ///
  /// In en, this message translates to:
  /// **'Select sector'**
  String get selectSectorPrompt;

  /// Azerbaijani sector
  ///
  /// In en, this message translates to:
  /// **'Azerbaijani'**
  String get sectorAzerbaijani;

  /// Russian sector
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get sectorRussian;

  /// English sector
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get sectorEnglish;

  /// Generic select placeholder
  ///
  /// In en, this message translates to:
  /// **'Select {item}'**
  String select(String item);

  /// Semantic label when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// Empty search state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// Account verification page title
  ///
  /// In en, this message translates to:
  /// **'Get Verified'**
  String get accountVerification;

  /// Get verified button
  ///
  /// In en, this message translates to:
  /// **'Get Verified'**
  String get getVerified;

  /// Verification call to action
  ///
  /// In en, this message translates to:
  /// **'Verify your student status'**
  String get verifyStudentStatus;

  /// Verified status badge
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Verification pending status
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// Verification under review message
  ///
  /// In en, this message translates to:
  /// **'Your verification is under review'**
  String get verificationUnderReview;

  /// Verification pending title
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get verificationPendingTitle;

  /// Verification pending message
  ///
  /// In en, this message translates to:
  /// **'We\'re checking your document. You\'ll be notified when it\'s done (usually 1-3 days).'**
  String get verificationPendingMessage;

  /// Verification rejected status
  ///
  /// In en, this message translates to:
  /// **'Verification Rejected'**
  String get verificationRejected;

  /// Try again message
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// Verification rejected title
  ///
  /// In en, this message translates to:
  /// **'Verification Rejected'**
  String get verificationRejectedTitle;

  /// Reason label
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get reason;

  /// Upload new screenshot instruction
  ///
  /// In en, this message translates to:
  /// **'Please upload a new screenshot from the MyGov app Education section'**
  String get uploadNewScreenshot;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Account verified title
  ///
  /// In en, this message translates to:
  /// **'You\'re Verified! 🎉'**
  String get accountVerifiedTitle;

  /// Account verified message
  ///
  /// In en, this message translates to:
  /// **'Your account is verified! You now have full access to all features.'**
  String get accountVerifiedMessage;

  /// Verification warning title
  ///
  /// In en, this message translates to:
  /// **'Heads Up!'**
  String get verificationWarningTitle;

  /// Verification warning message
  ///
  /// In en, this message translates to:
  /// **'Changing your university or faculty will reset your verification. You\'ll need to verify again.'**
  String get verificationWarningMessage;

  /// Verification document warning
  ///
  /// In en, this message translates to:
  /// **'Important: Only screenshots from MyGov app Education section are accepted. Student ID cards won\'t work.'**
  String get verificationWarning;

  /// Verification timeline info
  ///
  /// In en, this message translates to:
  /// **'Verification usually takes 1-3 business days. We\'ll notify you when it\'s complete.'**
  String get verificationTimeline;

  /// MyGov upload section title
  ///
  /// In en, this message translates to:
  /// **'MyGov Document Upload'**
  String get myGovDocumentUpload;

  /// MyGov upload instruction
  ///
  /// In en, this message translates to:
  /// **'Upload a screenshot of the Education section from your MyGov app'**
  String get myGovUploadInstruction;

  /// How to prepare section
  ///
  /// In en, this message translates to:
  /// **'How to prepare?'**
  String get howToPrepare;

  /// Verification step 1
  ///
  /// In en, this message translates to:
  /// **'1. Open the MyGov mobile app'**
  String get verificationStep1;

  /// Verification step 2
  ///
  /// In en, this message translates to:
  /// **'2. Go to the \'Education\' section'**
  String get verificationStep2;

  /// Verification step 3
  ///
  /// In en, this message translates to:
  /// **'3. Take a screenshot showing your student info'**
  String get verificationStep3;

  /// Verification step 4
  ///
  /// In en, this message translates to:
  /// **'4. Make sure the image is clear and readable'**
  String get verificationStep4;

  /// No screenshot selected message
  ///
  /// In en, this message translates to:
  /// **'No screenshot selected'**
  String get noScreenshotSelected;

  /// Select image prompt
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get pleaseSelectImage;

  /// Upload failed error
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// Document upload success
  ///
  /// In en, this message translates to:
  /// **'Document uploaded successfully!'**
  String get documentUploadedSuccessfully;

  /// Upload and send button
  ///
  /// In en, this message translates to:
  /// **'Upload and Send'**
  String get uploadAndSend;

  /// From gallery option
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Choose from gallery button
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Take photo button
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// Remove photo button
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Add image button
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// Attach image button
  ///
  /// In en, this message translates to:
  /// **'Attach Image'**
  String get attachImage;

  /// Change image button
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// Error picking image message
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// Error taking photo message
  ///
  /// In en, this message translates to:
  /// **'Error taking photo: {error}'**
  String errorTakingPhoto(String error);

  /// Image load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadError;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Notifications setting and page title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification settings page title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Enable notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Enable notifications description
  ///
  /// In en, this message translates to:
  /// **'Turn on/off all notifications'**
  String get enableNotificationsDescription;

  /// Empty notifications state
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// Notifications loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get errorLoadingNotifications;

  /// Settings loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get errorLoadingSettings;

  /// Mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Delete all button
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// Delete notification title
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotification;

  /// Delete notification confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this notification?'**
  String get deleteNotificationConfirm;

  /// Delete all notifications title
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications'**
  String get deleteAllNotifications;

  /// Delete all notifications confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications? This can\'t be undone.'**
  String get deleteAllNotificationsConfirm;

  /// Notification deleted success
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// Posts label
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// New posts notification setting
  ///
  /// In en, this message translates to:
  /// **'New Posts'**
  String get newPosts;

  /// New posts notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone posts'**
  String get newPostsDescription;

  /// New comments notification setting
  ///
  /// In en, this message translates to:
  /// **'New Comments'**
  String get newComments;

  /// New comments notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone comments on your posts'**
  String get newCommentsDescription;

  /// New likes notification setting
  ///
  /// In en, this message translates to:
  /// **'New Likes'**
  String get newLikes;

  /// New likes notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone likes your posts'**
  String get newLikesDescription;

  /// Comments label
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Comment replies notification setting
  ///
  /// In en, this message translates to:
  /// **'Comment Replies'**
  String get commentReplies;

  /// Comment replies notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone replies to your comments'**
  String get commentRepliesDescription;

  /// Mentions notification setting
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get mentions;

  /// Mentions notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone mentions you'**
  String get mentionsDescription;

  /// Chat messages notification setting
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get chatMessages;

  /// Chat messages notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified about new messages in faculty chat'**
  String get chatMessagesDescription;

  /// Chat mentions notification setting
  ///
  /// In en, this message translates to:
  /// **'Chat Mentions'**
  String get chatMentions;

  /// Chat mentions notification description
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone mentions you in chat'**
  String get chatMentionsDescription;

  /// Privacy and security setting
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// Help and support setting and page title
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// About setting
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// Profile page title and nav label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Profile update error
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// My posts section
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// Posts count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No posts} =1{1 post} other{{count} posts}}'**
  String postsCount(int count);

  /// Empty posts state
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// Empty user posts state
  ///
  /// In en, this message translates to:
  /// **'This user hasn\'t posted anything yet'**
  String get userHasNoPosts;

  /// Student ID card title
  ///
  /// In en, this message translates to:
  /// **'Student ID Card'**
  String get studentIdCard;

  /// ID label
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// Not available placeholder
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Verification required message
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// Verification required title
  ///
  /// In en, this message translates to:
  /// **'Get Verified First'**
  String get verificationRequiredTitle;

  /// Chat verification required message
  ///
  /// In en, this message translates to:
  /// **'Only verified students can chat. Complete verification to join the conversation.'**
  String get chatAccessVerifiedOnly;

  /// Verified users only notice
  ///
  /// In en, this message translates to:
  /// **'Only verified students can chat'**
  String get verifiedUsersOnly;

  /// Faculty students only notice
  ///
  /// In en, this message translates to:
  /// **'Students from your faculty only'**
  String get facultyStudentsOnly;

  /// Privacy notice
  ///
  /// In en, this message translates to:
  /// **'Private and secure communication'**
  String get privateAndSecure;

  /// Post restriction message
  ///
  /// In en, this message translates to:
  /// **'You can only post in your own university'**
  String get canOnlyPostInOwnUniversity;

  /// Chat page title and nav label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Connecting status
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// Chat description
  ///
  /// In en, this message translates to:
  /// **'This is the {facultyName} faculty chat. Only verified students can participate.'**
  String chatDescription(String facultyName);

  /// Empty chat state
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// Empty messages state title
  ///
  /// In en, this message translates to:
  /// **'No Messages Yet'**
  String get noMessagesYet;

  /// Empty chat call to action
  ///
  /// In en, this message translates to:
  /// **'Be the first to start the conversation!'**
  String get startConversation;

  /// Empty support messages state
  ///
  /// In en, this message translates to:
  /// **'Create your first support message to get help from our team'**
  String get createFirstSupportMessage;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// User typing indicator
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String userIsTyping(String name);

  /// Participants label
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// Participants count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No participants} =1{1 participant} other{{count} participants}}'**
  String participantsCount(int count);

  /// Total participants count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No participants} =1{1 participant} other{{count} participants}}'**
  String totalParticipants(int count);

  /// No participants title
  ///
  /// In en, this message translates to:
  /// **'No Participants'**
  String get noParticipants;

  /// No participants description
  ///
  /// In en, this message translates to:
  /// **'There are no participants in this chat yet'**
  String get noParticipantsDescription;

  /// Loading participants status
  ///
  /// In en, this message translates to:
  /// **'Loading participants...'**
  String get loadingParticipants;

  /// Yesterday time label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Weekday abbreviation
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{Mon} 2{Tue} 3{Wed} 4{Thu} 5{Fri} 6{Sat} 7{Sun} other{}}'**
  String weekday(String day);

  /// Days ago time label
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// New post page title
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// Post button
  ///
  /// In en, this message translates to:
  /// **'POST'**
  String get post;

  /// Title for the post detail page shown in the app bar
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postTitle;

  /// Anonymous user label
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Default user label
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Post content placeholder
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// Character count display
  ///
  /// In en, this message translates to:
  /// **'{current} / {max}'**
  String characterCount(int current, int max);

  /// Actions section header
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actions;

  /// Anonymous mode label
  ///
  /// In en, this message translates to:
  /// **'Anonymous Mode'**
  String get anonymousMode;

  /// Public mode label
  ///
  /// In en, this message translates to:
  /// **'Public Mode'**
  String get publicMode;

  /// Anonymous mode description
  ///
  /// In en, this message translates to:
  /// **'Your identity is hidden'**
  String get yourIdentityIsHidden;

  /// Public mode description
  ///
  /// In en, this message translates to:
  /// **'Your name is visible'**
  String get yourNameIsVisible;

  /// Enable anonymous mode tooltip
  ///
  /// In en, this message translates to:
  /// **'Post anonymously'**
  String get anonymousToggleEnable;

  /// Disable anonymous mode tooltip
  ///
  /// In en, this message translates to:
  /// **'Post with your name'**
  String get anonymousToggleDisable;

  /// Anonymous mode active label
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode is on'**
  String get anonymousToggleLabelOn;

  /// Anonymous mode inactive label
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode is off'**
  String get anonymousToggleLabelOff;

  /// Empty post error
  ///
  /// In en, this message translates to:
  /// **'Add some content or an image to post'**
  String get pleaseAddContent;

  /// Post created success
  ///
  /// In en, this message translates to:
  /// **'Posted! 🎉'**
  String get postCreatedSuccessfully;

  /// Post creation error
  ///
  /// In en, this message translates to:
  /// **'Failed to create post'**
  String get failedToCreatePost;

  /// Posts loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load posts'**
  String get failedToLoadPosts;

  /// Empty feed call to action
  ///
  /// In en, this message translates to:
  /// **'Be the first to share something!'**
  String get beTheFirstToShare;

  /// Post not found error
  ///
  /// In en, this message translates to:
  /// **'Post not found'**
  String get postNotFound;

  /// Post deleted message
  ///
  /// In en, this message translates to:
  /// **'This post may have been deleted'**
  String get postMayHaveBeenDeleted;

  /// Delete post title
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// Delete post confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get deletePostConfirmation;

  /// Like button label
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Likes label
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// Likes loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load likes'**
  String get failedToLoadLikes;

  /// Empty likes state
  ///
  /// In en, this message translates to:
  /// **'No likes yet'**
  String get noLikesYet;

  /// Empty likes call to action
  ///
  /// In en, this message translates to:
  /// **'Be the first to like this post'**
  String get beTheFirstToLike;

  /// Comment button label
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Empty comments state
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// Empty comments call to action
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get startTheConversation;

  /// Anonymous comment placeholder
  ///
  /// In en, this message translates to:
  /// **'Comment anonymously...'**
  String get commentAnonymously;

  /// Comment input placeholder
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// Delete comment title
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// Delete comment confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get deleteCommentConfirmation;

  /// Reply button label
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Replies count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No replies} =1{1 reply} other{{count} replies}}'**
  String repliesCount(int count);

  /// Anonymous reply placeholder
  ///
  /// In en, this message translates to:
  /// **'Reply anonymously...'**
  String get replyAnonymously;

  /// Reply input placeholder
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get writeReply;

  /// Delete reply title
  ///
  /// In en, this message translates to:
  /// **'Delete Reply'**
  String get deleteReply;

  /// Delete reply confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this reply?'**
  String get deleteReplyConfirmation;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Repost button label
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get repost;

  /// Feed navigation label
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// Search navigation label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Chat navigation label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Search users page title
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// Search users placeholder
  ///
  /// In en, this message translates to:
  /// **'Search users by name...'**
  String get searchUsersByName;

  /// Search users description
  ///
  /// In en, this message translates to:
  /// **'Search for users by name'**
  String get searchForUsers;

  /// Search minimum characters message
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to start searching'**
  String get typeToStartSearching;

  /// Empty search results
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// Empty search hint
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name'**
  String get tryDifferentName;

  /// Search results count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No users found} =1{1 user found} other{{count} users found}}'**
  String usersFound(int count);

  /// User not found error
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// Create support message button
  ///
  /// In en, this message translates to:
  /// **'Create Message'**
  String get createMessage;

  /// New message FAB label
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// Filter by status title
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// Clear filter button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilter;

  /// All messages filter option
  ///
  /// In en, this message translates to:
  /// **'All Messages'**
  String get allMessages;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// In progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Resolved status
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// Closed status
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// New support message page title
  ///
  /// In en, this message translates to:
  /// **'New Support Message'**
  String get newSupportMessage;

  /// Support response time info
  ///
  /// In en, this message translates to:
  /// **'Our support team typically responds within 24 hours'**
  String get supportTeamResponse;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Select category title
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Technical issue category
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get technicalIssue;

  /// Account issue category
  ///
  /// In en, this message translates to:
  /// **'Account Issue'**
  String get accountIssue;

  /// Verification category
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationCategory;

  /// Content issue category
  ///
  /// In en, this message translates to:
  /// **'Content Issue'**
  String get contentIssue;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Subject field hint
  ///
  /// In en, this message translates to:
  /// **'Brief description of your issue'**
  String get subjectHint;

  /// Subject validation error
  ///
  /// In en, this message translates to:
  /// **'Subject is required'**
  String get subjectRequired;

  /// Subject length validation
  ///
  /// In en, this message translates to:
  /// **'Subject must be less than 200 characters'**
  String get subjectTooLong;

  /// Message field label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Message field hint
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// Message validation error
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageRequired;

  /// Message length validation
  ///
  /// In en, this message translates to:
  /// **'Message must be less than 2000 characters'**
  String get messageTooLong;

  /// Submit message button
  ///
  /// In en, this message translates to:
  /// **'Submit Message'**
  String get submitMessage;

  /// Message sent success
  ///
  /// In en, this message translates to:
  /// **'Support message sent successfully!'**
  String get messageSentSuccess;

  /// Message details page title
  ///
  /// In en, this message translates to:
  /// **'Message Details'**
  String get messageDetails;

  /// Empty state message when user has seen all content
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// Technical support category
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get categoryTechnical;

  /// Account support category
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get categoryAccount;

  /// Verification support category
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get categoryVerification;

  /// Content support category
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get categoryContent;

  /// Other support category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Pending status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// In progress status label
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Resolved status label
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// Closed status label
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// Clear filter button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Date and time format
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year} at {hour}:{minute}'**
  String dateTimeFormat(
    int day,
    int month,
    int year,
    String hour,
    String minute,
  );

  /// Technical issue category label
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get categoryTechnicalIssue;

  /// Account issue category label
  ///
  /// In en, this message translates to:
  /// **'Account Issue'**
  String get categoryAccountIssue;

  /// Content issue category label
  ///
  /// In en, this message translates to:
  /// **'Content Issue'**
  String get categoryContentIssue;

  /// Info message about response time
  ///
  /// In en, this message translates to:
  /// **'Our support team typically responds within 24 hours'**
  String get supportResponseTime;

  /// Success message after sending support message
  ///
  /// In en, this message translates to:
  /// **'Support message sent successfully'**
  String get supportMessageSentSuccess;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: This action is permanent!'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently remove all your data from our servers. This includes:'**
  String get deleteAccountDescription;

  /// No description provided for @willBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'What will be deleted:'**
  String get willBeDeleted;

  /// No description provided for @allPosts.
  ///
  /// In en, this message translates to:
  /// **'All your posts'**
  String get allPosts;

  /// No description provided for @allComments.
  ///
  /// In en, this message translates to:
  /// **'All your comments'**
  String get allComments;

  /// No description provided for @profileData.
  ///
  /// In en, this message translates to:
  /// **'Your profile and personal data'**
  String get profileData;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone!'**
  String get thisActionCannotBeUndone;

  /// No description provided for @finalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm account deletion:'**
  String get typeDeleteToConfirm;

  /// No description provided for @pleaseTypeDeleteCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please type DELETE correctly to confirm'**
  String get pleaseTypeDeleteCorrectly;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @verificationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to be verified to access the chat. Please complete your verification first.'**
  String get verificationRequiredMessage;

  /// No description provided for @goToProfile.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile'**
  String get goToProfile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get deleteMessageConfirm;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message'**
  String get enterMessage;

  /// No description provided for @failedToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedToLoadMessages;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'(edited)'**
  String get edited;

  /// No description provided for @replyTo.
  ///
  /// In en, this message translates to:
  /// **'Reply to'**
  String get replyTo;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get appVersion;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Project Description'**
  String get projectDescription;

  /// No description provided for @aboutProjectText.
  ///
  /// In en, this message translates to:
  /// **'UniTalk is a modern mobile application developed as part of a student project for the \'Brand and Advertising\' course. The app is designed to improve communication between university students.'**
  String get aboutProjectText;

  /// No description provided for @courseInformation.
  ///
  /// In en, this message translates to:
  /// **'Course Information'**
  String get courseInformation;

  /// Subject field label
  ///
  /// In en, this message translates to:
  /// **'Subject:'**
  String get subject;

  /// No description provided for @brandAndAdvertising.
  ///
  /// In en, this message translates to:
  /// **'Brand and Advertising'**
  String get brandAndAdvertising;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group:'**
  String get group;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher:'**
  String get teacher;

  /// No description provided for @teacherName.
  ///
  /// In en, this message translates to:
  /// **'Lydia Safronova'**
  String get teacherName;

  /// No description provided for @projectTeam.
  ///
  /// In en, this message translates to:
  /// **'Project Team'**
  String get projectTeam;

  /// No description provided for @studentName1.
  ///
  /// In en, this message translates to:
  /// **'Rauf Khalilov'**
  String get studentName1;

  /// No description provided for @studentName2.
  ///
  /// In en, this message translates to:
  /// **'Taleh Badalov'**
  String get studentName2;

  /// No description provided for @studentName3.
  ///
  /// In en, this message translates to:
  /// **'Gunay Mirzayeva'**
  String get studentName3;

  /// No description provided for @studentName4.
  ///
  /// In en, this message translates to:
  /// **'Anastasia Lobastova'**
  String get studentName4;

  /// No description provided for @studentName5.
  ///
  /// In en, this message translates to:
  /// **'Ismayil Nagiyev'**
  String get studentName5;

  /// No description provided for @projectPurpose.
  ///
  /// In en, this message translates to:
  /// **'Project Purpose'**
  String get projectPurpose;

  /// No description provided for @purposeText.
  ///
  /// In en, this message translates to:
  /// **'Creating a convenient platform for student communication, information sharing, and collaborative work on educational projects.'**
  String get purposeText;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Group 787 students'**
  String get madeWithLove;

  /// No description provided for @universityInformation.
  ///
  /// In en, this message translates to:
  /// **'University Information'**
  String get universityInformation;

  /// No description provided for @universityName.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijan State University of Economics (UNEC)'**
  String get universityName;

  /// No description provided for @facultyName.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get facultyName;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get noBlockedUsers;

  /// No description provided for @blockUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block {name}?'**
  String blockUserConfirmation(Object name);

  /// No description provided for @unblockUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock {name}?'**
  String unblockUserConfirmation(Object name);

  /// No description provided for @youBlockedThisUser.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user'**
  String get youBlockedThisUser;

  /// No description provided for @thisUserBlockedYou.
  ///
  /// In en, this message translates to:
  /// **'This user blocked you'**
  String get thisUserBlockedYou;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get userBlocked;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully'**
  String get userUnblocked;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// No description provided for @reportComment.
  ///
  /// In en, this message translates to:
  /// **'Report Comment'**
  String get reportComment;

  /// No description provided for @reportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report Message'**
  String get reportMessage;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReports;

  /// No description provided for @selectReportCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectReportCategory;

  /// No description provided for @selectReportReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting'**
  String get selectReportReason;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmitted;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @cancelReport.
  ///
  /// In en, this message translates to:
  /// **'Cancel Report'**
  String get cancelReport;

  /// No description provided for @cancelReportConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this report?'**
  String get cancelReportConfirmation;

  /// No description provided for @spam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get spam;

  /// No description provided for @harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get harassment;

  /// No description provided for @hateSpeech.
  ///
  /// In en, this message translates to:
  /// **'Hate Speech'**
  String get hateSpeech;

  /// No description provided for @violence.
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get violence;

  /// No description provided for @nudity.
  ///
  /// In en, this message translates to:
  /// **'Nudity'**
  String get nudity;

  /// No description provided for @falseInformation.
  ///
  /// In en, this message translates to:
  /// **'False Information'**
  String get falseInformation;

  /// No description provided for @impersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get impersonation;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details (Optional)'**
  String get additionalDetails;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get describeIssue;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @likedByPrefix.
  ///
  /// In en, this message translates to:
  /// **'Liked by'**
  String get likedByPrefix;

  /// No description provided for @andOthers.
  ///
  /// In en, this message translates to:
  /// **'and {count} others'**
  String andOthers(int count);

  /// No description provided for @likesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likesCount(int count);

  /// Filters title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Active filters count suffix
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// Sort by section title
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Sort by newest option
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// Sort by popular option
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Azerbaijani sector filter
  ///
  /// In en, this message translates to:
  /// **'Azerbaijani'**
  String get sectorAz;

  /// Russian sector filter
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get sectorRu;

  /// English sector filter
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get sectorEn;

  /// All faculties filter option
  ///
  /// In en, this message translates to:
  /// **'All Faculties'**
  String get allFaculties;

  /// Clear all filters button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replyingTo;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @checkConnectionAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get checkConnectionAndRetry;

  /// No description provided for @announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @addMedia.
  ///
  /// In en, this message translates to:
  /// **'Add media'**
  String get addMedia;

  /// No description provided for @typeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type to confirm'**
  String get typeToConfirm;

  /// No description provided for @loadingImage.
  ///
  /// In en, this message translates to:
  /// **'Loading image...'**
  String get loadingImage;

  /// No description provided for @imageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadFailed;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get showOriginal;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed'**
  String get translationFailed;

  /// No description provided for @pinnedPost.
  ///
  /// In en, this message translates to:
  /// **'Pinned post'**
  String get pinnedPost;

  /// No description provided for @resubmissionInfo.
  ///
  /// In en, this message translates to:
  /// **'Please upload a new screenshot following the guidelines below.'**
  String get resubmissionInfo;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeFriendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this friend?'**
  String get removeFriendConfirmation;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @startAddingFriends.
  ///
  /// In en, this message translates to:
  /// **'Start adding friends to connect with them'**
  String get startAddingFriends;

  /// No description provided for @noIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests'**
  String get noIncomingRequests;

  /// No description provided for @noIncomingRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any pending friend requests'**
  String get noIncomingRequestsSubtitle;

  /// No description provided for @noOutgoingRequests.
  ///
  /// In en, this message translates to:
  /// **'No sent requests'**
  String get noOutgoingRequests;

  /// No description provided for @noOutgoingRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any friend requests yet'**
  String get noOutgoingRequestsSubtitle;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incoming;

  /// No description provided for @outgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoing;

  /// No description provided for @sentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentAt;

  /// No description provided for @friendsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No friends} =1{1 friend} other{{count} friends}}'**
  String friendsCount(int count);

  /// No description provided for @postNotificationFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter post notifications'**
  String get postNotificationFilter;

  /// No description provided for @allUniversities.
  ///
  /// In en, this message translates to:
  /// **'All universities'**
  String get allUniversities;

  /// No description provided for @allUniversitiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications from all universities'**
  String get allUniversitiesDescription;

  /// No description provided for @selectedUniversities.
  ///
  /// In en, this message translates to:
  /// **'Selected universities'**
  String get selectedUniversities;

  /// No description provided for @selectedUniversitiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose specific universities'**
  String get selectedUniversitiesDescription;

  /// No description provided for @universitiesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} universities selected'**
  String universitiesSelected(Object count);

  /// No description provided for @friendsOnly.
  ///
  /// In en, this message translates to:
  /// **'Friends only'**
  String get friendsOnly;

  /// No description provided for @friendsOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Only from people you follow'**
  String get friendsOnlyDescription;

  /// No description provided for @selectUniversities.
  ///
  /// In en, this message translates to:
  /// **'Select Universities'**
  String get selectUniversities;

  /// No description provided for @errorLoadingUniversities.
  ///
  /// In en, this message translates to:
  /// **'Error loading universities'**
  String get errorLoadingUniversities;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @myUniversity.
  ///
  /// In en, this message translates to:
  /// **'My university'**
  String get myUniversity;

  /// No description provided for @myUniversityDescription.
  ///
  /// In en, this message translates to:
  /// **'Only from students at my university'**
  String get myUniversityDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['az', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'az':
      return AppLocalizationsAz();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
