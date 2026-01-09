// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'Ka-Loumo';

  @override
  String get chat => 'Chat';

  @override
  String get messages => 'Messages';

  @override
  String get chatWithSeller => 'Chat with Seller';

  @override
  String get productSold => 'Product Sold';

  @override
  String get markAsSold => 'Mark as Sold';

  @override
  String get openingChat => 'Opening chat...';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get sold => 'SOLD';

  @override
  String get description => 'Description';

  @override
  String get sellerInfo => 'Seller Info';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Ka-Loumo';

  @override
  String get onboardingWelcomeDesc =>
      'The premium marketplace of Guinea Conakry.';

  @override
  String get onboardingBuySellTitle => 'Buy & Sell Easily';

  @override
  String get onboardingBuySellDesc =>
      'Publish items fast — find customers even faster.';

  @override
  String get onboardingChatTitle => 'Chat & Connect';

  @override
  String get onboardingChatDesc =>
      'Negotiate, chat, and complete deals securely.';

  @override
  String get btnNext => 'Next';

  @override
  String get btnGetStarted => 'Get Started';

  @override
  String get btnSkip => 'Skip';

  @override
  String get loginSubtitle => 'Connect to your marketplace';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginHint => 'Login using your phone number or email.';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get enterEmailFirst => 'Enter your email first';

  @override
  String resetLinkSent(Object email) {
    return 'Password reset link sent to $email';
  }

  @override
  String get resetFailed => 'Failed to send reset email';

  @override
  String get emailAndPasswordRequired => 'Email and password required';

  @override
  String get emailLoginFailed => 'Email login failed';

  @override
  String get phoneEnterNumber => 'Enter your phone number';

  @override
  String get otpFailed => 'Failed to send OTP';

  @override
  String get language => 'Language';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Sell & buy on Ka-Loumo.';

  @override
  String get registerFullName => 'Full name';

  @override
  String get registerEmailOptional => 'Email (optional)';

  @override
  String get registerPhone224 => 'Phone number (+224)';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get registerCreateAccountBtn => 'Create account';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account?';

  @override
  String get msgFullNameRequired => 'Full name is required';

  @override
  String get msgPhoneRequired => 'Phone number is required';

  @override
  String get msgPhoneMustStart224 => 'Phone must start with +224';

  @override
  String get msgPasswordRequired => 'Password is required';

  @override
  String get msgPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get msgAccountCreated => 'Account created successfully 🎉';

  @override
  String get msgRegistrationFailed => 'Registration failed';

  @override
  String get otpVerifyPhoneTitle => 'Verify Phone';

  @override
  String get otpEnterVerificationCodeTitle => 'Enter verification code';

  @override
  String otpSentTo(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get otpCodeLabel => '6-digit code';

  @override
  String get otpVerifyBtn => 'Verify';

  @override
  String get otpEnterCode => 'Enter the code';

  @override
  String get otpInvalidCode => 'Invalid code';

  @override
  String get catAll => 'All';

  @override
  String get catPhones => 'Phones';

  @override
  String get catFashion => 'Fashion';

  @override
  String get catCars => 'Cars';

  @override
  String get catElectronics => 'Electronics';

  @override
  String get popularItems => 'Popular Items';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get badgeNew => 'New';

  @override
  String get explore => 'Explore';

  @override
  String get noResults => 'No Results';

  @override
  String get untitled => 'Untitled';

  @override
  String get catRealEstate => 'Real Estate';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get addProduct => 'Add product';

  @override
  String get failedToLoadChats => 'Failed to load chats';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get deleteConversationTitle => 'Delete conversation?';

  @override
  String get deleteConversationBody =>
      'This will remove it from your inbox. You can recreate it later by chatting again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get userFallback => 'User';

  @override
  String get productFallback => 'Product';

  @override
  String get timeNow => 'now';

  @override
  String get upload => 'Upload';

  @override
  String get photos => 'Photos';

  @override
  String get details => 'Details';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'e.g. iPhone 13 Pro Max';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get titleTooShort => 'Title is too short.';

  @override
  String get priceGNF => 'Price (GNF)';

  @override
  String get priceHint => 'e.g. 650000';

  @override
  String get priceRequired => 'Price is required.';

  @override
  String get enterValidPrice => 'Enter a valid price.';

  @override
  String get descriptionHint =>
      'Add details: condition, accessories, defects, reason for sale…';

  @override
  String get descriptionRequired => 'Description is required.';

  @override
  String get descriptionTooShort => 'Description is too short.';

  @override
  String get categoryAndLocation => 'Category & Location';

  @override
  String get category => 'Category';

  @override
  String get condition => 'Condition';

  @override
  String get location => 'Location';

  @override
  String get addProductTip =>
      'Tip: better photos + clear details = more buyers.';

  @override
  String get addAtLeastOnePhoto => 'Please add at least 1 photo.';

  @override
  String get productUploaded => 'Product uploaded ✔';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get listingLimitReached => 'Listing limit reached';

  @override
  String get freeLimitReached => 'Free plan allows only';

  @override
  String get proLimitReached => 'You have reached your Pro limit';

  @override
  String get upgradeToPro => 'Upgrade to Pro to post more.';

  @override
  String get upgradeNotAddedYet => 'Upgrade screen not added yet (V1).';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get ok => 'OK';

  @override
  String get addUpTo8Photos => 'Add up to 8 photos';

  @override
  String get coverPhotoTip => 'Tip: first photo becomes your cover.';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get add => 'Add';

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get failedToLoadProduct => 'Failed to load product';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get soldUnavailable => 'SOLD • UNAVAILABLE';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get sellerTitle => 'Seller';

  @override
  String get markAsSoldTitle => 'Mark as sold?';

  @override
  String get markAsSoldBody =>
      'This will disable chat and mark this product as sold.';

  @override
  String get loadingSeller => 'Loading seller...';

  @override
  String get sellerFallback => 'Seller';

  @override
  String get tapToViewProfile => 'Tap to view profile';

  @override
  String get sellerProfileTitle => 'Seller Profile';

  @override
  String get sellerNotFound => 'Seller not found';

  @override
  String get sellerRatingLabel => 'Seller rating';

  @override
  String get listingsTitle => 'Listings';

  @override
  String get failedToLoadProducts => 'Failed to load products';

  @override
  String get noProductsFromSeller => 'No products from this seller';

  @override
  String get soldLabel => 'SOLD';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profilePhotoHint => 'A clear photo helps build trust';

  @override
  String get change => 'Change';

  @override
  String get remove => 'Remove';

  @override
  String get fullName => 'Full Name';

  @override
  String get bio => 'Bio';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get profileUpdated => 'Profile updated ✔';

  @override
  String updateFailed(Object error) {
    return 'Update failed: $error';
  }

  @override
  String get logoutTitle => 'Logout?';

  @override
  String get logoutBody => 'Are you sure you want to log out of your account?';

  @override
  String get logout => 'Logout';

  @override
  String logoutFailed(Object error) {
    return 'Logout failed: $error';
  }

  @override
  String get noProfileFound => 'No profile found';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get pro => 'PRO';

  @override
  String get listings => 'Listings';

  @override
  String get rating => 'Rating';

  @override
  String ratingCountLabel(int count) {
    return '($count ratings)';
  }

  @override
  String get myListings => 'My Listings';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get help => 'Help';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get call => 'Call';

  @override
  String get helpNeedHelpTitle => 'Need help?';

  @override
  String get helpNeedHelpSubtitle => 'Contact us directly. We respond fast.';

  @override
  String get helpWhatsappMessage => 'Hello Ka-Loumo Support, I need help.';

  @override
  String get helpEmailSubject => 'Ka-Loumo Support';

  @override
  String get helpEmailBody => 'Hello,\n\nI need help with Ka-Loumo.\n\nThanks.';

  @override
  String get helpFooter => 'Ka-Loumo • Guinea 🇬🇳';

  @override
  String get unableToOpenAction => 'Unable to open this action';

  @override
  String get checkoutCouldNotStart => 'Could not start checkout.';

  @override
  String get unableToOpenPaymentPage => 'Unable to open payment page.';

  @override
  String get paymentError => 'Payment error';

  @override
  String get upgradeToProTitle => 'Upgrade to Pro?';

  @override
  String get upgradeToProBody =>
      'You’ll be redirected to Stripe to complete payment.\n\nAfter successful payment, Pro is activated automatically.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get youAreOnPro => 'You\'re on Pro';

  @override
  String get youAreOnFree => 'You\'re on Free';

  @override
  String activeListingsLabel(int active, int limit) {
    return 'Active listings: $active / $limit';
  }

  @override
  String get planFreeTitle => 'Free';

  @override
  String get planFreePrice => '0 GNF';

  @override
  String get planFreeBadge => 'Default';

  @override
  String get planFreeFeature1 => 'Post up to 3 active listings';

  @override
  String get planFreeFeature2 => 'Chat with buyers/sellers';

  @override
  String get planFreeFeature3 => 'Basic profile';

  @override
  String get planProTitle => 'Pro';

  @override
  String get planProPrice => 'Stripe';

  @override
  String get planProBadge => 'Recommended';

  @override
  String get planProFeature1 => 'Post up to 50 active listings';

  @override
  String get planProFeature2 => 'More visibility (later)';

  @override
  String get planProFeature3 => 'Seller badge (later)';

  @override
  String get alreadyPro => 'Already Pro ✅';

  @override
  String get upgradeToProButton => 'Upgrade to Pro';

  @override
  String get proAutoActivatesHint =>
      'Pro activates automatically after Stripe confirms payment.';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get failedToLoadFavorites => 'Failed to load favorites.';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle => 'Start adding items you like ❤️';

  @override
  String get myListingsTitle => 'My Listings';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get failedToLoadListings => 'Failed to load listings.';

  @override
  String get noListingsYet => 'No listings yet';

  @override
  String get listingsEmptySubtitle => 'Your products will appear here';

  @override
  String get deleteProductTitle => 'Delete product';

  @override
  String get deleteProductBody =>
      'Are you sure you want to delete this listing? This action cannot be undone.';

  @override
  String get listingDeletedSuccess => 'Listing deleted ✅';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get edit => 'Edit';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Change app language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsChangePasswordSubtitle => 'Update your password';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our policy';

  @override
  String get termsTitle => 'Terms';

  @override
  String get termsSubtitle => 'Read terms of use';

  @override
  String get unableToOpenLink => 'Unable to open link';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get showPasswords => 'Show passwords';

  @override
  String get fillAllFields => 'Fill all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get passwordUpdated => 'Password updated ✅';

  @override
  String get noEmailPasswordLogin =>
      'This account has no email/password login.';

  @override
  String get failed => 'Failed';

  @override
  String get error => 'Error';

  @override
  String get update => 'Update';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get save => 'Save';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get catHome => 'Home';

  @override
  String get catOthers => 'Others';

  @override
  String get newCondition => 'New';

  @override
  String get used => 'Used';

  @override
  String get msgLoginRequired => 'Please log in to continue.';

  @override
  String get paymentSuccessTitle => 'Payment successful';

  @override
  String get paymentSuccessBody =>
      'Your upgrade was successful. Pro features will be activated shortly.';

  @override
  String get paymentCanceledTitle => 'Payment canceled';

  @override
  String get paymentCanceledBody =>
      'The upgrade process was canceled. No charges were made.';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';
}
