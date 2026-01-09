import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ff.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ss.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('ff'),
    Locale('fr'),
    Locale('ml'),
    Locale('ss'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ka-Loumo'**
  String get appTitle;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @chatWithSeller.
  ///
  /// In en, this message translates to:
  /// **'Chat with Seller'**
  String get chatWithSeller;

  /// No description provided for @productSold.
  ///
  /// In en, this message translates to:
  /// **'Product Sold'**
  String get productSold;

  /// No description provided for @markAsSold.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sold'**
  String get markAsSold;

  /// No description provided for @openingChat.
  ///
  /// In en, this message translates to:
  /// **'Opening chat...'**
  String get openingChat;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'SOLD'**
  String get sold;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @sellerInfo.
  ///
  /// In en, this message translates to:
  /// **'Seller Info'**
  String get sellerInfo;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ka-Loumo'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'The premium marketplace of Guinea Conakry.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingBuySellTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell Easily'**
  String get onboardingBuySellTitle;

  /// No description provided for @onboardingBuySellDesc.
  ///
  /// In en, this message translates to:
  /// **'Publish items fast — find customers even faster.'**
  String get onboardingBuySellDesc;

  /// No description provided for @onboardingChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat & Connect'**
  String get onboardingChatTitle;

  /// No description provided for @onboardingChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Negotiate, chat, and complete deals securely.'**
  String get onboardingChatDesc;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get btnGetStarted;

  /// No description provided for @btnSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get btnSkip;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to your marketplace'**
  String get loginSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Login using your phone number or email.'**
  String get loginHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first'**
  String get enterEmailFirst;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}'**
  String resetLinkSent(Object email);

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get resetFailed;

  /// No description provided for @emailAndPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password required'**
  String get emailAndPasswordRequired;

  /// No description provided for @emailLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Email login failed'**
  String get emailLoginFailed;

  /// No description provided for @phoneEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneEnterNumber;

  /// No description provided for @otpFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get otpFailed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sell & buy on Ka-Loumo.'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullName;

  /// No description provided for @registerEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get registerEmailOptional;

  /// No description provided for @registerPhone224.
  ///
  /// In en, this message translates to:
  /// **'Phone number (+224)'**
  String get registerPhone224;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPassword;

  /// No description provided for @registerCreateAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccountBtn;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @msgFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get msgFullNameRequired;

  /// No description provided for @msgPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get msgPhoneRequired;

  /// No description provided for @msgPhoneMustStart224.
  ///
  /// In en, this message translates to:
  /// **'Phone must start with +224'**
  String get msgPhoneMustStart224;

  /// No description provided for @msgPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get msgPasswordRequired;

  /// No description provided for @msgPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get msgPasswordsDoNotMatch;

  /// No description provided for @msgAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully 🎉'**
  String get msgAccountCreated;

  /// No description provided for @msgRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get msgRegistrationFailed;

  /// No description provided for @otpVerifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get otpVerifyPhoneTitle;

  /// No description provided for @otpEnterVerificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get otpEnterVerificationCodeTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpCodeLabel;

  /// No description provided for @otpVerifyBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyBtn;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpEnterCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get otpInvalidCode;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catPhones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get catPhones;

  /// No description provided for @catFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get catFashion;

  /// No description provided for @catCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get catCars;

  /// No description provided for @catElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get catElectronics;

  /// No description provided for @popularItems.
  ///
  /// In en, this message translates to:
  /// **'Popular Items'**
  String get popularItems;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @catRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get catRealEstate;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @failedToLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @deleteConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get deleteConversationTitle;

  /// No description provided for @deleteConversationBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove it from your inbox. You can recreate it later by chatting again.'**
  String get deleteConversationBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @productFallback.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productFallback;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. iPhone 13 Pro Max'**
  String get titleHint;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get titleRequired;

  /// No description provided for @titleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title is too short.'**
  String get titleTooShort;

  /// No description provided for @priceGNF.
  ///
  /// In en, this message translates to:
  /// **'Price (GNF)'**
  String get priceGNF;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 650000'**
  String get priceHint;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required.'**
  String get priceRequired;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price.'**
  String get enterValidPrice;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add details: condition, accessories, defects, reason for sale…'**
  String get descriptionHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required.'**
  String get descriptionRequired;

  /// No description provided for @descriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Description is too short.'**
  String get descriptionTooShort;

  /// No description provided for @categoryAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Category & Location'**
  String get categoryAndLocation;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @addProductTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: better photos + clear details = more buyers.'**
  String get addProductTip;

  /// No description provided for @addAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 photo.'**
  String get addAtLeastOnePhoto;

  /// No description provided for @productUploaded.
  ///
  /// In en, this message translates to:
  /// **'Product uploaded ✔'**
  String get productUploaded;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @listingLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Listing limit reached'**
  String get listingLimitReached;

  /// No description provided for @freeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free plan allows only'**
  String get freeLimitReached;

  /// No description provided for @proLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your Pro limit'**
  String get proLimitReached;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to post more.'**
  String get upgradeToPro;

  /// No description provided for @upgradeNotAddedYet.
  ///
  /// In en, this message translates to:
  /// **'Upgrade screen not added yet (V1).'**
  String get upgradeNotAddedYet;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @addUpTo8Photos.
  ///
  /// In en, this message translates to:
  /// **'Add up to 8 photos'**
  String get addUpTo8Photos;

  /// No description provided for @coverPhotoTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: first photo becomes your cover.'**
  String get coverPhotoTip;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsTitle;

  /// No description provided for @failedToLoadProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product'**
  String get failedToLoadProduct;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @soldUnavailable.
  ///
  /// In en, this message translates to:
  /// **'SOLD • UNAVAILABLE'**
  String get soldUnavailable;

  /// No description provided for @descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionTitle;

  /// No description provided for @sellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerTitle;

  /// No description provided for @markAsSoldTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as sold?'**
  String get markAsSoldTitle;

  /// No description provided for @markAsSoldBody.
  ///
  /// In en, this message translates to:
  /// **'This will disable chat and mark this product as sold.'**
  String get markAsSoldBody;

  /// No description provided for @loadingSeller.
  ///
  /// In en, this message translates to:
  /// **'Loading seller...'**
  String get loadingSeller;

  /// No description provided for @sellerFallback.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerFallback;

  /// No description provided for @tapToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Tap to view profile'**
  String get tapToViewProfile;

  /// No description provided for @sellerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Profile'**
  String get sellerProfileTitle;

  /// No description provided for @sellerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Seller not found'**
  String get sellerNotFound;

  /// No description provided for @sellerRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller rating'**
  String get sellerRatingLabel;

  /// No description provided for @listingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listingsTitle;

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// No description provided for @noProductsFromSeller.
  ///
  /// In en, this message translates to:
  /// **'No products from this seller'**
  String get noProductsFromSeller;

  /// No description provided for @soldLabel.
  ///
  /// In en, this message translates to:
  /// **'SOLD'**
  String get soldLabel;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @profilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'A clear photo helps build trust'**
  String get profilePhotoHint;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated ✔'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(Object error);

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutBody;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(Object error);

  /// No description provided for @noProfileFound.
  ///
  /// In en, this message translates to:
  /// **'No profile found'**
  String get noProfileFound;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUser;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @ratingCountLabel.
  ///
  /// In en, this message translates to:
  /// **'({count} ratings)'**
  String ratingCountLabel(int count);

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @helpNeedHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get helpNeedHelpTitle;

  /// No description provided for @helpNeedHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us directly. We respond fast.'**
  String get helpNeedHelpSubtitle;

  /// No description provided for @helpWhatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello Ka-Loumo Support, I need help.'**
  String get helpWhatsappMessage;

  /// No description provided for @helpEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Ka-Loumo Support'**
  String get helpEmailSubject;

  /// No description provided for @helpEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\nI need help with Ka-Loumo.\n\nThanks.'**
  String get helpEmailBody;

  /// No description provided for @helpFooter.
  ///
  /// In en, this message translates to:
  /// **'Ka-Loumo • Guinea 🇬🇳'**
  String get helpFooter;

  /// No description provided for @unableToOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this action'**
  String get unableToOpenAction;

  /// No description provided for @checkoutCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Could not start checkout.'**
  String get checkoutCouldNotStart;

  /// No description provided for @unableToOpenPaymentPage.
  ///
  /// In en, this message translates to:
  /// **'Unable to open payment page.'**
  String get unableToOpenPaymentPage;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error'**
  String get paymentError;

  /// No description provided for @upgradeToProTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro?'**
  String get upgradeToProTitle;

  /// No description provided for @upgradeToProBody.
  ///
  /// In en, this message translates to:
  /// **'You’ll be redirected to Stripe to complete payment.\n\nAfter successful payment, Pro is activated automatically.'**
  String get upgradeToProBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @youAreOnPro.
  ///
  /// In en, this message translates to:
  /// **'You\'re on Pro'**
  String get youAreOnPro;

  /// No description provided for @youAreOnFree.
  ///
  /// In en, this message translates to:
  /// **'You\'re on Free'**
  String get youAreOnFree;

  /// No description provided for @activeListingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active listings: {active} / {limit}'**
  String activeListingsLabel(int active, int limit);

  /// No description provided for @planFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFreeTitle;

  /// No description provided for @planFreePrice.
  ///
  /// In en, this message translates to:
  /// **'0 GNF'**
  String get planFreePrice;

  /// No description provided for @planFreeBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get planFreeBadge;

  /// No description provided for @planFreeFeature1.
  ///
  /// In en, this message translates to:
  /// **'Post up to 3 active listings'**
  String get planFreeFeature1;

  /// No description provided for @planFreeFeature2.
  ///
  /// In en, this message translates to:
  /// **'Chat with buyers/sellers'**
  String get planFreeFeature2;

  /// No description provided for @planFreeFeature3.
  ///
  /// In en, this message translates to:
  /// **'Basic profile'**
  String get planFreeFeature3;

  /// No description provided for @planProTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planProTitle;

  /// No description provided for @planProPrice.
  ///
  /// In en, this message translates to:
  /// **'Stripe'**
  String get planProPrice;

  /// No description provided for @planProBadge.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get planProBadge;

  /// No description provided for @planProFeature1.
  ///
  /// In en, this message translates to:
  /// **'Post up to 50 active listings'**
  String get planProFeature1;

  /// No description provided for @planProFeature2.
  ///
  /// In en, this message translates to:
  /// **'More visibility (later)'**
  String get planProFeature2;

  /// No description provided for @planProFeature3.
  ///
  /// In en, this message translates to:
  /// **'Seller badge (later)'**
  String get planProFeature3;

  /// No description provided for @alreadyPro.
  ///
  /// In en, this message translates to:
  /// **'Already Pro ✅'**
  String get alreadyPro;

  /// No description provided for @upgradeToProButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToProButton;

  /// No description provided for @proAutoActivatesHint.
  ///
  /// In en, this message translates to:
  /// **'Pro activates automatically after Stripe confirms payment.'**
  String get proAutoActivatesHint;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @failedToLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites.'**
  String get failedToLoadFavorites;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding items you like ❤️'**
  String get favoritesEmptySubtitle;

  /// No description provided for @myListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListingsTitle;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @failedToLoadListings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load listings.'**
  String get failedToLoadListings;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsYet;

  /// No description provided for @listingsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your products will appear here'**
  String get listingsEmptySubtitle;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing? This action cannot be undone.'**
  String get deleteProductBody;

  /// No description provided for @listingDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted ✅'**
  String get listingDeletedSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our policy'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read terms of use'**
  String get termsSubtitle;

  /// No description provided for @unableToOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link'**
  String get unableToOpenLink;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @showPasswords.
  ///
  /// In en, this message translates to:
  /// **'Show passwords'**
  String get showPasswords;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get fillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated ✅'**
  String get passwordUpdated;

  /// No description provided for @noEmailPasswordLogin.
  ///
  /// In en, this message translates to:
  /// **'This account has no email/password login.'**
  String get noEmailPasswordLogin;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @catHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get catHome;

  /// No description provided for @catOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get catOthers;

  /// No description provided for @newCondition.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCondition;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @msgLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue.'**
  String get msgLoginRequired;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your upgrade was successful. Pro features will be activated shortly.'**
  String get paymentSuccessBody;

  /// No description provided for @paymentCanceledTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment canceled'**
  String get paymentCanceledTitle;

  /// No description provided for @paymentCanceledBody.
  ///
  /// In en, this message translates to:
  /// **'The upgrade process was canceled. No charges were made.'**
  String get paymentCanceledBody;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'ff',
    'fr',
    'ml',
    'ss',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ff':
      return AppLocalizationsFf();
    case 'fr':
      return AppLocalizationsFr();
    case 'ml':
      return AppLocalizationsMl();
    case 'ss':
      return AppLocalizationsSs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
